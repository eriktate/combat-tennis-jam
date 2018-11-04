{.passL:"-s", optimization: speed.}
import
  strformat,
  math,
  times

import
  sdl2,
  sdl2/image

import
  sprite,
  animation,
  math2d,
  input

type SDLException = object of Exception

template sdlFailIf(cond: typed, reason: string) =
  if cond: raise SDLException.newException(reason & ", SDL error: " & $getError())

# Global data
var
  should_quit: bool = false
  elapsed_time: float = 0.0
  inputs: array[Input, bool]
  face: Sprite
  racket: Sprite
  ball: Sprite
  ball_direction: Vec2D = (x: 1.0, y: 1.0)
  ball_is_hit = false
  prev_racket_rot: float = 0.0

proc update() =
  let
    mouse_point = getMousePoint()
    new_x: float = inputs[Input.right].float - inputs[Input.left].float
    new_y: float = -(inputs[Input.up].float - inputs[Input.down].float)
    dest = rect(500.cint, 200.cint, face.w.cint, face.h.cint)

  face.pos = face.pos + (newVec2D(new_x, new_y) * 0.4)
  racket.pos = (face.pos - racket.center + face.center)

  let rotation_vec = newVec2D(newVec2D(mouse_point), racket.pos + racket.center)

  racket.rot = rotation_vec.angle

  let swing_arc: Arc = (origin: racket.origin, inner: 24.0, outer: 45.0, ang1: racket.rot, ang2: prev_racket_rot)
  prev_racket_rot = racket.rot

  let ball_hitbox: Circle = (origin: ball.origin, radius: ball.w/2)

  if intersect(ball_hitbox, swing_arc) and not ball_is_hit:
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

proc draw(renderer: RendererPtr, sprites: var seq[Sprite]) =
  renderer.clear()
  for spr in sprites.mitems():
    renderer.copyEx(spr.tex, spr.texRect(elapsed_time), spr.destRect(), angle = radToDeg(spr.rot), center = addr spr.center, flip = SDL_FLIP_NONE)
  renderer.present()

proc gracefulShutdown() {.noconv.} =
  echo("Shutting down...")
  should_quit = true

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

  # initialize game objects
  face = newSprite(newVec2D(500, 200), renderer.loadTexture("assets/sprites/face.png"), 32, 32, Point((x: 16.cint, y: 16.cint)))
  racket = newSprite(newVec2D(564, 200), renderer.loadTexture("assets/sprites/racket.png"), 32, 32, Point((x: 64.cint, y: 16.cint)))
  ball = newSprite(newVec2D(600, 332), renderer.loadTexture("assets/sprites/ball.png"), 16, 16, Point((x: 8.cint, y: 8.cint)))

  face.anim = newAnimation(10.0, @[0, 0, 0, 0, 0, 0, 1, 2, 1, 0, 0, 0, 0, 3, 4, 4, 4, 4, 3])

  var
    sprites: seq[Sprite] = @[face, racket, ball]
    last_time: float = cpuTime()

  while not should_quit:
    let current_time: float = cpuTime()
    elapsed_time = current_time - last_time
    last_time = current_time

    # collect input
    handleInput(inputs)

    # simulation
    update()

    # render
    draw(renderer, sprites)

setControlCHook(gracefulShutdown)
main()
