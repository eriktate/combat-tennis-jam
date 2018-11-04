type Animation* = tuple[idx: float, framerate: float, frames: seq[int]]

func newAnimation*(framerate: float, frames: seq[int]): Animation =
  result.idx = 0
  result.framerate = framerate
  result.frames = frames

proc tick*(this: var Animation, elapsed: float): int =
  this.idx += elapsed * this.framerate

  if this.idx.int >= this.frames.len:
    # this.idx -= this.frames.len.float
    this.idx = 0.0

  this.frames[this.idx.int]
