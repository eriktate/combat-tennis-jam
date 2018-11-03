import unittest
import math

import math2d

suite "vec2D":
  test "vector addition":
    let
      vec1: Vec2D = (x: 2.0, y: 3.0)
      vec2: Vec2D = (x: 4.0, y: 5.0)

    let added = vec1 + vec2

    check(added.x == 6.0)
    check(added.y == 8.0)

  test "vector subtraction":
    let
      vec1: Vec2D = (x: 2.0, y: 3.0)
      vec2: Vec2D = (x: 4.0, y: 5.0)

    let added = vec1 - vec2

    check(added.x == -2.0)
    check(added.y == -2.0)

  test "scalar multiplication":
    let
      vec1: Vec2D = (x: 2.0, y: 3.0)

    let added = vec1 * 2.0

    check(added.x == 4.0)
    check(added.y == 6.0)

  test "vector equality":
    let
      vec1: Vec2D = (x: 2.0, y: 3.0)
      vec2: Vec2D = (x: 2.0, y: 3.0)
      vec3: Vec2D = (x: 2.0, y: 1.0)
      vec4: Vec2D = (x: 1.0, y: 3.0)

    check(vec1 == vec2)
    check(vec1 != vec3)
    check(vec1 != vec4)

  test "vector magnitude":
    let vec: Vec2D = (x: 2.0, y: 3.0)

    check(mag(vec) > 3.605 and mag(vec) < 3.6056)

  test "quad conversion and equality":
    let
      rec: Rectangle = (x: 2.0, y: 3.0, w: 4.0, h: 4.0)
      tl: Vec2D = (x: 2.0, y: 3.0)
      br: Vec2D = (x: 6.0, y: 7.0)
      expected_quad: Quad = (tl: tl, br: br)
      bad: Quad = (tl * 2, br * 5)

    check(rec.toQuad == expected_quad)
    check(rec.toQuad != bad)

  test "rectangle conversion and equality":
    let
      tl: Vec2D = (x: 2.0, y: 3.0)
      br: Vec2D = (x: 4.0, y: 6.0)
      quad: Quad = (tl: tl, br: br)
      expected: Rectangle = (x: 2.0, y: 3.0, w: 2.0, h: 3.0)
      bad: Rectangle = (x: 1.0, y: 5.0, w: 3.5, h: 6.9)

    check(quad.toRectangle == expected)
    check(quad.toRectangle != bad)

  test "quad translation":
    let
      tl: Vec2D = (x: 2.0, y: 3.0)
      br: Vec2D = (x: 4.0, y: 6.0)
      vec: Vec2D = (x: 2.0, y: 2.0)
      ex_tl: Vec2D = (x: 4.0, y: 5.0)
      ex_br: Vec2D = (x: 6.0, y: 8.0)
      expected: Quad = (ex_tl, ex_br)

    var quad: Quad = (tl: tl, br: br)

    translate(quad, vec)
    check(quad == expected)


  test "vector intersection":
    let
      tl: Vec2D = (x: 2.0, y: 3.0)
      br: Vec2D = (x: 4.0, y: 6.0)
      quad: Quad = (tl: tl, br: br)
      test_vec: Vec2D = (x: 3.0, y: 4.0)
      left: Vec2D = (x: 1.0, y: 4.0)
      right: Vec2D = (x: 5.0, y: 4.0)
      up: Vec2D = (x: 3.0, y: 1.0)
      down: Vec2D = (x: 3.0, y: 7.0)

    check(intersect(test_vec, quad))
    check(not intersect(left, quad))
    check(not intersect(right, quad))
    check(not intersect(up, quad))
    check(not intersect(down, quad))

  test "quad overlap":
    let
      tl: Vec2D = (x: 2.0, y: 3.0)
      br: Vec2D = (x: 4.0, y: 6.0)
      quad: Quad = (tl: tl, br: br)
      trans_vec: Vec2D = (x: 1.0, y: 2.0)

    var overlapping: Quad = quad

    translate(overlapping, trans_vec)
    check(overlap(quad, overlapping))

    translate(overlapping, trans_vec * 5)
    check(not overlap(quad, overlapping))

  test "vector rotation":
    let
      vec: Vec2D = (x: 1.0, y: 0.0)
      expected: Vec2D = (x: 0.0, y: 1.0)
      rotation = PI / 2

    check(vec.rot(rotation) == expected)
