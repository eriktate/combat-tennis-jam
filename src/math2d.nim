# vector2d
# adding vectors
# subtracting vectors
# dot product
# scalar mult
import math
import strformat

import sdl2

type
  Vec2D* = tuple[x: float, y: float]
  Rectangle* = tuple[x, y, w, h: float]
  Quad* = tuple[tl, br: Vec2D]
  Circle* = tuple[origin: Vec2D, radius: float]
  Arc* = tuple[origin: Vec2D, inner, outer, ang1, ang2: float ]

func newVec2D*(x, y: float): Vec2D =
  result.x = x
  result.y = y

func newVec2D*(a, b: Vec2D): Vec2D =
  result.x = (a.x - b.x)
  result.y = (a.y - b.y)

func newVec2D*(point: Point): Vec2D =
  result.x = point.x.float
  result.y = point.y.float

# TODO (erik): Figure out why PI has to be added here.
func newPolarVec2D*(magnitude: float, theta: float): Vec2D =
  result.y = magnitude * sin(theta + PI)
  result.x = magnitude * cos(theta + PI)

func newRectangle*(x, y, w, h: float): Rectangle =
  result = (x: x, y: y, w: w, h: h)

func newQuad*(tl, br: Vec2D): Quad =
  result = (tl: tl, br: br)

func `+`*(left: Vec2D, right: Vec2D): Vec2D =
  result.x = left.x + right.x
  result.y = left.y + right.y

func `+`*(left: Vec2D, right: Point): Vec2D =
  result.x = left.x + right.x.float
  result.y = left.y + right.y.float

func `-`*(left: Vec2D, right: Vec2D): Vec2D =
  result.x = left.x - right.x
  result.y = left.y - right.y

func `-`*(left: Vec2D, right: Point): Vec2D =
  result.x = left.x - right.x.float
  result.y = left.y - right.y.float

func `*`*(left: Vec2D, right: Vec2D): float =
  left.x * right.x + left.y * right.y

func `*`*(vec: Vec2D, scalar: float): Vec2D =
  result.x = vec.x * scalar
  result.y = vec.y * scalar

# func `*`*(vec: Vec2D, scalar: int): Vec2D =
#   result.x = vec.x * scalar.float
#   result.y = vec.y * scalar.float

func `==`*(left: Vec2D, right: Vec2D): bool  =
  left.x == right.x and left.y == right.y

func `!=`*(left: Vec2D, right: Vec2D): bool =
  not (left == right)

func `==`*(left: Quad, right: Quad): bool =
  left.tl == right.tl and left.br == right.br

func `!=`*(left: Quad, right: Quad): bool =
  not (left == right)

func `==`*(left: Rectangle, right: Rectangle): bool =
  left.x == right.x and left.y == right.y and
    left.w == right.w and left.y == right.y

func `!=`*(left: Rectangle, right: Rectangle): bool =
  not (left == right)

func mag*(vec: Vec2D): float =
  sqrt(vec.x * vec.x + vec.y * vec.y)

func unit*(vec: Vec2D): Vec2D =
  let magnitude: float = mag(vec)
  result.x = vec.x / magnitude
  result.y = vec.y / magnitude

func angle*(vec: Vec2D): float =
  arctan2(vec.y, vec.x)

func toPoint*(vec: Vec2D): Point =
  result.x = vec.x.cint
  result.y = vec.y.cint

func toQuad*(rec: Rectangle): Quad =
  let
    tl: Vec2D = (x: rec.x, y: rec.y)
    br: Vec2D = (x: rec.x + rec.w, y: rec.y + rec.h)

  result = (tl: tl, br: br)

func toRectangle*(quad: Quad): Rectangle =
  let
    x: float = quad.tl.x
    y: float = quad.tl.y
    w: float = quad.br.x - quad.tl.x
    h: float = quad.br.y - quad.tl.y

  result = (x: x, y: y, w: w, h: h)

# TODO (erik): Should this just return a new quad instead of mutating?
proc translate*(quad: var Quad, vec: Vec2D) =
  quad.tl = quad.tl + vec
  quad.br = quad.br + vec

# TODO (erik): Same as above
proc scale*(quad: var Quad, scale: float) =
  quad.br = quad.br * scale

func rot*(vec: Vec2D, rad: float): Vec2D =
  result.x = vec.x * cos(rad) - vec.y * sin(rad)
  result.y = vec.x * sin(rad) + vec.y * cos(rad)

  if result.x < 0.00000001:
    result.x = 0.0
  if result.y < 0.00000001:
    result.y = 0.0

func intersect*(vec: Vec2D, quad: Quad): bool =
  (vec.x > quad.tl.x) and (vec.y > quad.tl.y) and
    (vec.x < quad.br.x) and (vec.y < quad.br.y)

func intersect*(vec: Vec2D, rec: Rectangle): bool =
  intersect(vec, rec.toQuad)

func between(target, ang1, ang2: float): bool =
  let rAngle = ((ang2 - ang1) mod 360 + 360) mod 360

  var a1 = ang1
  var a2 = ang2
  if rAngle >= 180:
    a1 = ang2
    a2 = ang1

  if a1 <= a2:
    target >= a1 and target <= a2
  else:
    target >= a1 or target <= a2

# check circle-line intersection
func intersect*(start, `end`: Vec2D, circle: Circle): bool =
  let
    src = start - circle.origin
    dest = `end` - circle.origin

  let
    d = dest - src
    a = d * d
    b = 2 * (src * d)
    c = (src * src) - pow(circle.radius, 2.0)
    determinant = pow(b, 2.0) - 4 * a * c

  if determinant < 0:
    return false

  let
    t1 = (-b + sqrt(determinant)) / (2 * a)
    t2 = (-b - sqrt(determinant)) / (2 * a)

  if (t1 < 0 or t1 > 1) and (t2 < 0 or t2 > 1):
    return false
  return true

func intersect*(circle: Circle, arc: Arc): bool =
  let
    diff = newVec2D(arc.origin, circle.origin)
    distance = diff.mag
    angle = diff.angle

  if (distance < arc.inner - circle.radius) or distance > (arc.outer + circle.radius):
    return false

  if between(radToDeg(angle), radToDeg(arc.ang1), radToDeg(arc.ang2)):
    return true

  let
    vec_a: Vec2D = arc.origin + newPolarVec2D(arc.outer, arc.ang1)
    vec_b: Vec2D = arc.origin + newPolarVec2D(arc.outer, arc.ang2)

  if intersect(arc.origin, vec_a, circle) or intersect(arc.origin, vec_b, circle):
    return true

  return false

func overlap*(src, dest: Quad): bool =
  let
    tr: Vec2D = (x: src.br.x, y: src.tl.y)
    bl: Vec2D = (x: src.tl.x, y: src.br.y)

  intersect(src.tl, dest) or intersect(tr, dest) or intersect(src.br, dest) or intersect(bl, dest)

func overlap*(src, dest: Rectangle): bool =
  overlap(src.toQuad, dest.toQuad)

