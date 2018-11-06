import
  sdl2

type SDLException* = object of Exception

template sdlFailIf*(cond: typed, reason: string) =
  if cond: raise SDLException.newException(reason & ", SDL error: " & $getError())
