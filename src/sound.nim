import
  sdl2/mixer

import
  sdl

type
  NamedSound* = tuple[key: string, chunk: ptr Chunk]
  SoundManager* = ref object
    sounds: seq[NamedSound]

var manager: SoundManager = nil

proc newSoundManager(): SoundManager =
  new result

proc getSoundManager*(): SoundManager =
  if manager == nil:
    manager = newSoundManager()
  return manager

proc register*(this: var SoundManager, key: string, fname: string): NamedSound =
  let chunk = loadWAV(fname)

  sdlFailIf(chunk == nil):
    "Could not load sound from " & fname

  result = (key: key, chunk: chunk)
  this.sounds.add(result)

proc get*(this: SoundManager, key: string): NamedSound =
  for sound in this.sounds:
    if key == key:
      result = sound

proc play*(this: NamedSound) =
  discard playChannel(-1, this.chunk, 0)

proc play*(this: SoundManager, key: string) =
  this.get(key).play()
