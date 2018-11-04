import strformat
import math
import times

import sdl2
import sdl2/image

import sprite
import animation
import math2d

type SDLException = object of Exception

template sdlFailIf(cond: typed, reason: string) =
  if cond: raise SDLException.newException(reason & ", SDL error: " & $getError())

type
  Input {.pure.} = enum none, left, right, up, down, restart, quit
  Game = ref object
    inputs: array[Input, bool]
    renderer: RendererPtr
    player: Sprite

proc getMousePoint(): Point =
  var
    x: cint = 0.cint
    y: cint = 0.cint

  getMouseState(x, y)
  result = (x: x, y: y)

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

  # const imgFlags: cint = IMG_INIT_PNG
  # sdlFailIf(image.init(imgFlags) != imgFlags):
  #   "SDL2 Image initialization failed"
  # defer: image.quit()

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

  var
    face: Sprite = newSprite(newVec2D(500, 200), renderer.loadTexture("assets/sprites/face.png"), 32, 32, Point((x: 16.cint, y: 16.cint)))
    racket: Sprite = newSprite(newVec2D(564, 200), renderer.loadTexture("assets/sprites/racket.png"), 48, 32, Point((x: 64.cint, y: 16.cint)))
    ball: Sprite = newSprite(newVec2D(600, 332), renderer.loadTexture("assets/sprites/ball.png"), 16, 16, Point((x: 8.cint, y: 8.cint)))
    game = newGame(renderer)
    dest = rect(500.cint, 200.cint, face.w.cint, face.h.cint)
    prev_racket_rot: float = 0.0
    ball_is_hit = false
    ball_direction: Vec2D = (x: 1.0, y: 1.0)
    last_time: float = cpuTime()

  face.anim = newAnimation(10.0, @[0, 0, 0, 0, 0, 0, 1, 2, 1, 0, 0, 0, 0, 3, 4, 4, 4, 4, 3])
  game.player = face
  while true:
    let
      current_time: float = cpuTime()
      elapsed_time: float = current_time - last_time
      mouse_point = getMousePoint()
      rotation_vec = newVec2D(racket.pos + racket.center, newVec2D(mouse_point))
      new_x: float = game.inputs[Input.right].float - game.inputs[Input.left].float
      new_y: float = -(game.inputs[Input.up].float - game.inputs[Input.down].float)

    racket.rot = rotation_vec.angle
    last_time = current_time

    game.handleInput()
    racket.pos = (face.pos - racket.center + face.center)
    game.player.pos = game.player.pos + (newVec2D(new_x, new_y) * 0.4)

    let swing_arc: Arc = (origin: racket.origin, inner: 24.0, outer: 45.0, ang1: racket.rot, ang2: prev_racket_rot)
    prev_racket_rot = racket.rot
    let ball_hitbox: Circle = (origin: ball.origin, radius: ball.w/2)

    if intersect(ball_hitbox,swing_arc) and not ball_is_hit:
      echo("Hit!")
      let my_vec: Vec2D = unit(ball.origin - racket.origin)
      ball_direction.x = my_vec.y
      ball_direction.y = -my_vec.x
      ball_is_hit = true

    ball.pos = ball.pos + (ball_direction)
    if ball.pos.x < 0 or ball.pos.x > 1280:
      ball_direction.x *= -1
      ball_is_hit = false
    if ball.pos.y < 0 or ball.pos.y > 720:
      ball_direction.y *= -1
      ball_is_hit = false

    renderer.clear()
    # renderer.copyEx(racket.tex, racket.texRect(elapsedTime), racket.destRect(), angle = radToDeg(racket.rot), center = addr(racket.center), flip = SDL_FLIP_NONE)
    renderer.copyEx(face.tex, face.texRect(elapsed_time), face.destRect(), angle = 0.0, center = nil, flip = SDL_FLIP_NONE)
    # renderer.copyEx(ball.tex, ball.texRect(elapsed_time), ball.destRect(), angle = 0.0, center = nil, flip = SDL_FLIP_NONE)
    renderer.present()

main()
