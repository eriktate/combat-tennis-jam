import strformat

import sdl2
import sdl2/image

import math2d
import animation

const defaultCenter: Point = (x: 0.cint, y: 0.cint)

type Sprite* = ref object
  pos*: Vec2D
  tex*: TexturePtr
  w*, h*: int
  rot*: float
  center*: Point
  anim*: Animation
  tex_w: cint
  tex_h: cint
  rect: Rect
  dest: Rect

func rect*(this: Sprite): Rectangle =
  newRectangle(this.pos.x, this.pos.y, this.w.float, this.h.float)

proc texRect*(this: var Sprite, elapsed: float): var Rect =
  let
    idx: int = this.anim.tick(elapsed)
    cell_w: int = (this.tex_w / this.w).int
    cell_h: int = (this.tex_h / this.h).int

    row: int = (idx / cell_w).int
    col: int = idx mod cell_w
    tex_w: int = this.tex_w
    tex_h: int = this.tex_h

  if row > cell_h:
    echo("Invalid row value!")

  this.rect = rect((col * this.w).cint, (row * this.h).cint, this.w.cint, this.h.cint)
  return this.rect

proc destRect*(this: var Sprite): var Rect =
  let
    x: cint = this.pos.x.cint
    y: cint = this.pos.y.cint
    w: cint = this.w.cint
    h: cint = this.h.cint

  this.dest = rect(x, y, w, h)
  return this.dest

func quad*(this: Sprite): Quad =
  let br: Vec2D = (x: this.pos.x + this.w.float, y: this.pos.y + this.h.float)
  newQuad(this.pos, br)

func origin*(this: Sprite): Vec2D =
  return this.pos + this.center

func newSprite*(pos: Vec2D, tex: TexturePtr, w, h: int, center: Point = defaultCenter): Sprite =
  new result
  queryTexture(tex, nil, nil, addr result.tex_w, addr result.tex_h)
  result.tex = tex
  result.pos = pos
  result.w = w
  result.h = h
  result.rot = 0.0
  result.center = center
  result.anim = newAnimation(0, @[0])
