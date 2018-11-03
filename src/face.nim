import strformat

import sdl2
import sdl2/image

import math2d

type Face* = ref object
  pos*: Vec2D
  tex*: TexturePtr
  w*, h*: int
  rect: Rect
  dest: Rect

func rect*(this: Face): Rectangle =
  newRectangle(this.pos.x, this.pos.y, this.w.float, this.h.float)

proc texRect*(this: var Face): var Rect =
  this.rect = rect(0.cint, 0.cint, this.w.cint, this.h.cint)
  return this.rect

proc destRect*(this: var Face): var Rect =
  let
    x: cint = this.pos.x.cint
    y: cint = this.pos.y.cint
    w: cint = this.w.cint
    h: cint = this.h.cint

  this.dest = rect(x, y, w, h)
  return this.dest

func quad*(this: Face): Quad =
  let br: Vec2D = (x: this.pos.x + this.w.float, y: this.pos.y + this.h.float)
  newQuad(this.pos, br)

func newFace*(pos: Vec2D, tex: TexturePtr, w, h: int): Face =
  new result
  result.tex = tex
  result.pos = pos
  result.w = w
  result.h = h
