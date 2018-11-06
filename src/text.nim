import
  sdl2,
  sdl2/ttf

import
  math2d

type
  Text* = object
    pos*: Vec2D
    tex*: TexturePtr

    text: string
    tex_w: cint
    tex_h: cint
    dest: Rect

  DebugPanel* = tuple[renderer: RendererPtr, current: string, next: string, text: Text]

proc newText*(renderer: RendererPtr, text: string, pos: Vec2D): Text =
  let font: FontPtr = openFont("assets/fonts/system.ttf".cstring, 24.cint)
  defer: close(font)
  let white = color(255, 255, 255, 255)
  let surface = renderTextSolid(font, text, white)
  result.tex = renderer.createTextureFromSurface(surface)
  queryTexture(result.tex, nil, nil, addr result.tex_w, addr result.tex_h)
  result.text = text
  result.pos = pos

proc destRect*(this: var Text): var Rect =
  let
    x: cint = this.pos.x.cint
    y: cint = this.pos.y.cint
    w: cint = this.tex_w.cint
    h: cint = this.tex_h.cint

  this.dest = rect(x, y, w, h)
  return this.dest

proc newDebugPanel*(renderer: RendererPtr, message: string): DebugPanel =
  result.renderer = renderer
  result.next = message

proc print*(this: var DebugPanel, message: string) =
  this.next = this.next & message & "\n"

proc flush*(this: var DebugPanel) =
  this.current = this.next
  this.text = newText(this.renderer, this.current, newVec2D(0.0, 0.0))

