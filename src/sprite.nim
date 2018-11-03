import strformat

import sdl2
import sdl2/image

import math2d

const defaultCenter: Point = (x: 0.cint, y: 0.cint)

type Sprite* = ref object
  pos*: Vec2D
  tex*: TexturePtr
  w*, h*: int
  rot*: float
  center*: Point
  rect: Rect
  dest: Rect

func rect*(this: Sprite): Rectangle =
  newRectangle(this.pos.x, this.pos.y, this.w.float, this.h.float)

proc texRect*(this: var Sprite): var Rect =
  this.rect = rect(0.cint, 0.cint, this.w.cint, this.h.cint)
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

func newSprite*(pos: Vec2D, tex: TexturePtr, w, h: int, center: Point = defaultCenter): Sprite =
  new result
  result.tex = tex
  result.pos = pos
  result.w = w
  result.h = h
  result.rot = 0.0
  result.center = center
