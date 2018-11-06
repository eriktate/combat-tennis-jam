import
  strformat

import
  sdl2

import
  math2d,
  text

type
  DebugLine = tuple[key: string, val: string, dirty: bool]

  Debug* = ref object
    debug_lines: seq[DebugLine]
    tex_lines: seq[Text]
    renderer: RendererPtr

proc newDebug*(renderer: RendererPtr): Debug =
  new result
  result.renderer = renderer

func newDebugLine*(key, val: string): DebugLine =
  result.key = key
  result.val = val
  result.dirty = true

proc addLine*(this: var Debug, key: string, val: string = "") =
  this.debug_lines.add(newDebugLine(key, val))
  this.tex_lines.add(newText(this.renderer, "", newVec2D(0.0, (this.tex_lines.len * 28).float)))

proc log*(this: var Debug, key, val: string) =
  for line in this.debug_lines.mitems():
    if line.key == key and line.val != val:
      echo("Test")
      line.val = val
      line.dirty = true
      return

  echo("Adding line!")
  this.addline(key, val)


proc flush*(this: Debug): var seq[Text] =
  for i, line in this.debug_lines.mpairs():
    if line.dirty:
      let
        pos = this.tex_lines[i].pos
        message = &"{line.key}: {line.val}"

      this.tex_lines[i] = newText(this.renderer, message, pos)
      line.dirty = false

  return this.tex_lines
