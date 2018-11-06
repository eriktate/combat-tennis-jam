import
  sdl2

type
  Input* {.pure.} = enum none, left, right, up, down, restart, quit

func getMousePoint*(): Point =
  var
    x: cint = 0.cint
    y: cint = 0.cint

  getMouseState(x, y)
  result = (x: x, y: y)

func toInput(key: ScanCode): Input =
  case key
  of SDL_SCANCODE_A: Input.left
  of SDL_SCANCODE_D: Input.right
  of SDL_SCANCODE_W: Input.up
  of SDL_SCANCODE_S: Input.down
  of SDL_SCANCODE_Q: Input.quit
  else: Input.none

proc handleInput*(inputs: var array[Input, bool]) =
  var event = defaultEvent
  while pollEvent(event):
    case event.kind
    of QuitEvent:
      inputs[Input.quit] = true
    of KeyDown:
      inputs[event.key.keysym.scancode.toInput] = true
    of KeyUp:
      inputs[event.key.keysym.scancode.toInput] = false
    else:
      discard
