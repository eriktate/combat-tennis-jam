import sdl2
import sdl2/image

import math2d

type Face* = object
  pos*: Vec2D
  tex*: TexturePtr
  w*, h*: int
  rect: Rect

func rect*(this: Face): Rectangle =
  newRectangle(this.pos.x, this.pos.y, this.w.float, this.h.float)

func texRect*(this: var Face): var Rect =
  this.rect = rect(0.cint, 0.cint, this.w.cint, this.h.cint)

func quad*(this: Face): Quad =
  let br: Vec2D = (x: this.pos.x + this.w.float, y: this.pos.y + this.h.float)
  newQuad(this.pos, br)

func newFace*(pos: Vec2D, tex: TexturePtr, w, h: int): Face =
  result.tex = tex
  result.pos = pos
  result.w = w
  result.h = h
