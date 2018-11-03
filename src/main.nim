import sdl2
import sdl2/image

import face
import math2d

type SDLException = object of Exception

template sdlFailIf(cond: typed, reason: string) =
  if cond: raise SDLException.newException(reason & ", SDL error: " & $getError())

type
  Input {.pure.} = enum none, left, right, up, down, restart, quit
  Game = ref object
    inputs: array[Input, bool]
    renderer: RendererPtr

proc toInput(key: ScanCode): Input =
  case key
  of SDL_SCANCODE_A: Input.left
  of SDL_SCANCODE_D: Input.right
  of SDL_SCANCODE_W: Input.up
  of SDL_SCANCODE_S: Input.down
  of SDL_SCANCODE_Q: Input.quit
  else: Input.none

proc handleInput(game: Game) =
  var event = defaultEvent
  while pollEvent(event):
    case event.kind
    of QuitEvent:
      game.inputs[Input.quit] = true
    of KeyDown:
      game.inputs[event.key.keysym.scancode.toInput] = true
    of KeyUp:
      game.inputs[event.key.keysym.scancode.toInput] = false
    else:
      discard

proc render(game: Game) =
  game.renderer.clear()
  game.renderer.present()

proc newGame(renderer: RendererPtr): Game =
  new result
  result.renderer = renderer

proc main =
  sdlFailIf(not sdl2.init(INIT_VIDEO or INIT_TIMER or INIT_EVENTS)):
    "SDL2 initialization failed"
  defer: sdl2.quit()

  const imgFlags: cint = IMG_INIT_PNG
  sdlFailIf(image.init(imgFlags) != imgFlags):
    "SDL2 Image initialization failed"
  defer: image.quit()

  sdlFailIf(not setHint("SDL_RENDER_SCALE_QUALITY", "2")):
    "Linear texture filtering could not be enabled"

  let window = createWindow(title = "Combat Tennis Jam", x = SDL_WINDOWPOS_CENTERED,
    y = SDL_WINDOWPOS_CENTERED, w = 1280, h = 720, flags = SDL_WINDOW_SHOWN)
  sdlFailIf window.isNil: "Window could not be created"
  defer: window.destroy()

  let renderer = window.createRenderer(index = -1, flags = Renderer_Accelerated or Renderer_PresentVsync)
  sdlFailIf renderer.isNil: "Renderer could not be created"
  defer: renderer.destroy()

  renderer.setDrawColor(r = 118, g = 66, b = 138)

  var f: Face = newFace(newVec2D(500, 200), renderer.loadTexture("assets/sprites/face.png"), 32, 32)
  var game = newGame(renderer)
  # var src = rect(0.cint, 0.cint, f.w.cint, f.h.cint) # TODO (erik): Figure out how to get this from Face.
  var dest = rect(500.cint, 200.cint, f.w.cint, f.h.cint)
  while true:
    game.handleInput()
    renderer.clear()
    renderer.copyEx(f.tex, f.texRect(), dest, angle = 0.0, center = nil, flip = SDL_FLIP_NONE)
    renderer.present()

main()
