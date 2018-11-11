import
  sdl2

import
  math2d

type Image = object
  pos*: Vec2D
  w*: int
  h*: int
  x_scale*: float
  y_scale*: float
  index*: int
  angle*: float
  flip*: cint
  tex: TexturePtr
  tex_w: cint
  tex_h: cint
  src: Rect
  dest: Rect
  center: Point

const defaultCenter: Point = (x: 0.cint, y: 0.cint)

proc newImage*(tex: TexturePtr, center: Point = defaultCenter): Image =
  queryTexture(tex, nil, nil, addr result.tex_w, addr result.tex_h)
  result.tex = tex
  result.center = center

proc srcRect*(this: var Image): var Rect =
  let
    cell_w: int = (this.tex_w / this.w).int
    cell_h: int = (this.tex_h / this.h).int

    row: int = (this.index / cell_w).int
    col: int = this.index mod cell_w
    tex_w: int = this.tex_w
    tex_h: int = this.tex_h

  if row > cell_h:
    echo("Index out of bounds!")

  this.src = rect((col * this.w).cint, (row * this.h).cint, this.w.cint, this.h.cint)
  return this.src

proc destRect*(this: var Image): var Rect =
  let
    x: cint = this.pos.x.cint
    y: cint = this.pos.y.cint
    w: cint = (this.w.float * this.x_scale).cint
    h: cint = (this.h.float * this.y_scale).cint

  this.dest = rect(x, y, w, h)
  return this.dest
