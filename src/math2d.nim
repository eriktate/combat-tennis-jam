# vector2d
# adding vectors
# subtracting vectors
# dot product
# scalar mult
import math

type
  Vec2D* = tuple[x: float, y: float]
  Rectangle* = tuple[x, y, w, h: float]
  Quad* = tuple[tl, br: Vec2D]

func `+`*(left: Vec2D, right: Vec2D): Vec2D =
  result.x = left.x + right.x
  result.y = left.y + right.y

func `-`*(left: Vec2D, right: Vec2D): Vec2D =
  result.x = left.x - right.x
  result.y = left.y - right.y

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

func unit*(vec: Vec2D): Vec2D =
  let magnitude: float = mag(vec)
  result.x = vec.x / magnitude
  result.y = vec.y / magnitude

func intersect*(vec: Vec2D, quad: Quad): bool =
  (vec.x > quad.tl.x) and (vec.y > quad.tl.y) and
    (vec.x < quad.br.x) and (vec.y < quad.br.y)

func intersect*(vec: Vec2D, rec: Rectangle): bool =
  intersect(vec, rec.toQuad)

func overlap*(src, dest: Quad): bool =
  let
    tr: Vec2D = (x: src.br.x, y: src.tl.y)
    bl: Vec2D = (x: src.tl.x, y: src.br.y)

  intersect(src.tl, dest) or intersect(tr, dest) or intersect(src.br, dest) or intersect(bl, dest)

func overlap*(src, dest: Rectangle): bool =
  overlap(src.toQuad, dest.toQuad)

