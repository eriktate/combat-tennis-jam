# {.passL:"-s", optimization: speed.}
import
  strformat,
  math,
  times

import
  sdl2,
  sdl2/image,
  sdl2/ttf,
  sdl2/mixer

import
  sdl,
  sprite,
  text,
  animation,
  debug,
  math2d,
  input,
  sound,
  gamepad


const
  window_width: cint = 1280
  window_height: cint = 720
# Global data
var
  should_quit: bool = false
  dt: float = 0.0
  inputs: array[Input, bool]
  player: Sprite
  racket: Sprite
  ball: Sprite
  court: Sprite
  ball_direction: Vec2D = (x: 1.0, y: 1.0)
  ball_is_hit = false
  prev_racket_rot: float = 0.0
  deb: Debug
  hit_count: int = 0
  fps: int = 0
  frame_count: int = 0
  elapsed_time: float = 0.0
  sound_manager: SoundManager = getSoundManager()
  gp: Gamepad

proc check_fps() =
  elapsed_time += dt
  frame_count += 1

  if elapsed_time >= 1.0:
    elapsed_time = 0.0
    fps = frame_count
    frame_count = 0

proc init(renderer: RendererPtr) =
  # initialize game objects
  gp = newGamepad()

  player = newSprite(newVec2D(500, 200), renderer.loadTexture("assets/sprites/space_man_sheet.png"), 64, 64, Point((x: 32.cint, y: 32.cint)), 32, 32)
  racket = newSprite(newVec2D(564, 200), renderer.loadTexture("assets/sprites/racket.png"), 32, 32, Point((x: 64.cint, y: 16.cint)))
  ball = newSprite(newVec2D(600, 332), renderer.loadTexture("assets/sprites/ball.png"), 16, 16, Point((x: 8.cint, y: 8.cint)))
  court = newSprite(newVec2D((window_width.float/2 - 720/2), 0.0), renderer.loadTexture("assets/sprites/grass_court.png"), 720, 720)

  # initailize sounds
  discard sound_manager.register("racket", "assets/sounds/racket.wav")

  deb = newDebug(renderer)

  player.addAnim("idle_right", newAnimation(20.0, @[0]))
  player.addAnim("idle_left", newAnimation(20.0, @[13]))
  player.addAnim("run_right", newAnimation(20.0, @[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]))
  player.addAnim("run_left", newAnimation(20.0, @[14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]))
  player.setAnim("idle_right")

proc update() =
  let
    mouse_point = getMousePoint()
    new_x: float = inputs[Input.right].float - inputs[Input.left].float
    new_y: float = -(inputs[Input.up].float - inputs[Input.down].float)
    dest = rect(500.cint, 200.cint, player.w.cint, player.h.cint)
    dir_vec = gp.leftStickVec

  check_fps()
  deb.log("fps", $fps)

  player.pos = player.pos + (dir_vec * 512 * dt)
  racket.pos = (player.pos - racket.center + player.center)

  if dir_vec.x > 0:
    player.facing = Direction.right

  if dir_vec.x < 0:
    player.facing = Direction.left

  if (dir_vec.mag == 0):
    player.setAnim("idle_" & $player.facing)
  else:
    player.setAnim("run_" & $player.facing)


  # let rotation_vec = newVec2D(newVec2D(mouse_point), racket.pos + racket.center)
  let rotation_vec = gp.rightStickVec

  racket.rot = rotation_vec.angle

  let swing_arc: Arc = (origin: racket.origin, inner: 24.0, outer: 45.0, ang1: racket.rot, ang2: prev_racket_rot)
  prev_racket_rot = racket.rot

  let ball_hitbox: Circle = (origin: ball.origin, radius: ball.w/2)

  if intersect(ball_hitbox, swing_arc) and not ball_is_hit:
    let my_vec: Vec2D = unit(ball.origin - racket.origin)
    ball_direction.x = my_vec.y
    ball_direction.y = -my_vec.x
    ball_is_hit = true
    hit_count += 1
    deb.log("hit_count", $hit_count)
    sound_manager.play("racket")

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
    renderer.copyEx(spr.tex, spr.texRect(dt), spr.destRect(), angle = radToDeg(spr.rot), center = addr spr.center, flip = SDL_FLIP_NONE)

  for tx in deb.flush().mitems():
    renderer.copy(tx.tex, nil, addr tx.destRect)

  renderer.present()

proc gracefulShutdown() {.noconv.} =
  echo("Shutting down...")
  should_quit = true

proc main =
  sdlFailIf(not sdl2.init(INIT_VIDEO or INIT_TIMER or INIT_EVENTS or INIT_AUDIO or INIT_JOYSTICK)):
    "SDL2 initialization failed"
  defer: sdl2.quit()

  const imgFlags: cint = IMG_INIT_PNG
  sdlFailIf(image.init(imgFlags) != imgFlags):
    "SDL2 Image initialization failed"
  defer: image.quit()

  sdlFailIf(ttfInit().int != 0):
    "SDL2 TTF initialization failed"
  defer: ttfQuit()

  sdlFailIf(openAudio(44100.cint, MIX_DEFAULT_FORMAT, 2.cint, 2048.cint) < 0):
    "SDL2 Mixer initialization failed"

  sdlFailIf(not setHint("SDL_RENDER_SCALE_QUALITY", "0")):
    "Linear texture filtering could not be enabled"

  # sdlFailIf(not setHint("SDL_HINT_GAMECONTROLLERCONFIG"))

  let window = createWindow(title = "Combat Tennis Jam", x = SDL_WINDOWPOS_CENTERED,
    y = SDL_WINDOWPOS_CENTERED, w = window_width, h = window_height, flags = SDL_WINDOW_SHOWN)
  sdlFailIf window.isNil: "Window could not be created"
  defer: window.destroy()

  let renderer = window.createRenderer(index = -1, flags = Renderer_Accelerated or Renderer_PresentVsync)
  sdlFailIf renderer.isNil: "Renderer could not be created"
  defer: renderer.destroy()

  renderer.setDrawColor(r = 118, g = 66, b = 138)

  init(renderer)

  var
    sprites: seq[Sprite] = @[court, player, racket, ball]
    last_time: float = cpuTime()


  while not should_quit:
    let current_time: float = cpuTime()
    dt = current_time - last_time
    last_time = current_time

    # collect input
    handleInput(inputs)

    # simulation
    update()

    # render
    draw(renderer, sprites)

setControlCHook(gracefulShutdown)
main()
