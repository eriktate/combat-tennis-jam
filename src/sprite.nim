import
  strformat,
  tables

import
  sdl2,
  sdl2/image

import
  math2d,
  animation

const defaultCenter: Point = (x: 0.cint, y: 0.cint)

type
  Direction* = enum
    left = "left"
    right = "right"

  Sprite* = ref object
    pos*: Vec2D
    tex*: TexturePtr
    w*, h*: int
    rot*: float
    center*: Point
    frame_w*: int
    frame_h*: int
    facing*: Direction
    current_key: string
    anims: Table[string, Animation]
    anim: Animation
    tex_w: cint
    tex_h: cint
    rect: Rect
    dest: Rect

proc newSprite*(pos: Vec2D, tex: TexturePtr, w, h: int, center: Point = defaultCenter, frame_w: int = 0, frame_h: int = 0): Sprite =
  new result
  queryTexture(tex, nil, nil, addr result.tex_w, addr result.tex_h)
  result.tex = tex
  result.pos = pos
  result.w = w
  result.h = h
  result.rot = 0.0
  result.center = center
  result.anim = newAnimation(0, @[0])
  result.anims = initTable[string, Animation]()

  if frame_w == 0:
    result.frame_w = w
  else:
    result.frame_w = frame_w
  if frame_h == 0:
    result.frame_h = h
  else:
    result.frame_h = frame_h

func rect*(this: Sprite): Rectangle =
  newRectangle(this.pos.x, this.pos.y, this.w.float, this.h.float)

proc texRect*(this: var Sprite, dt: float): var Rect =
  let
    idx: int = this.anim.tick(dt)
    cell_w: int = (this.tex_w / this.frame_w).int
    cell_h: int = (this.tex_h / this.frame_h).int

    row: int = (idx / cell_w).int
    col: int = idx mod cell_w
    tex_w: int = this.tex_w
    tex_h: int = this.tex_h

  if row > cell_h:
    echo("Invalid row value!")

  this.rect = rect((col * this.frame_w).cint, (row * this.frame_h).cint, this.frame_w.cint, this.frame_h.cint)
  return this.rect

proc destRect*(this: var Sprite): var Rect =
  let
    x: cint = this.pos.x.cint
    y: cint = this.pos.y.cint
    w: cint = this.w.cint
    h: cint = this.h.cint

  this.dest = rect(x, y, w, h)
  return this.dest

proc addAnim*(this: var Sprite, key: string, anim: Animation) =
  this.anims[key] = anim

proc setAnim*(this: var Sprite, key: string) =
  if key != this.current_key:
    this.anim = this.anims[key]
    this.current_key = key

func quad*(this: Sprite): Quad =
  let br: Vec2D = (x: this.pos.x + this.w.float, y: this.pos.y + this.h.float)
  newQuad(this.pos, br)

func origin*(this: Sprite): Vec2D =
  return this.pos + this.center

