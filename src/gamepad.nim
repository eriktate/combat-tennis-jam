import
  sdl2/gamecontroller,
  sdl2/joystick

import
  math2d

const max_stick_value = 32767
const deadzone_min = 0.5

type
  Gamepad* = object
    controller: GameControllerPtr
    left: Vec2D
    right: Vec2D

  Stick* = enum
    leftStick
    rightStick

func newGamepad*(id: int = -1): Gamepad =
  if id > 0:
    result.controller = gameControllerOpen(id.cint)

  for i in 0..numJoysticks():
    if isGameController(i).bool:
      result.controller = gameControllerOpen(i)

func getStickVec(this: Gamepad, stick: Stick): Vec2D =
  let
    x: int16 = this.controller.getAxis(if stick == leftStick: SDL_CONTROLLER_AXIS_LEFTX else: SDL_CONTROLLER_AXIS_RIGHTX)
    y: int16 = this.controller.getAxis(if stick == leftStick: SDL_CONTROLLER_AXIS_LEFTY else: SDL_CONTROLLER_AXIS_RIGHTY)

  result = newVec2D(x / max_stick_value, y / max_stick_value)

func constrain*(vec: Vec2D): Vec2D =
  if vec.mag < deadzone_min:
    result.x = 0.0
    result.y = 0.0
  else:
    result = vec

func deadzone*(this: Gamepad, vec: Vec2D): Vec2D =
  if vec.mag < deadzone_min:
    return this.right
  return vec

func leftStickVec*(this: var Gamepad): Vec2D =
  this.left = getStickVec(this, leftStick).constrain
  return this.left

func rightStickVec*(this: var Gamepad): Vec2D =
  this.right = this.deadzone(getStickVec(this, rightStick))
  return this.right

