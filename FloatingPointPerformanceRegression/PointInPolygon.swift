//
//  PointInPolygon.swift
//  FloatingPointPerformanceRegression
//
//  Created by Xiaodi Wu on 8/1/16.
//  Copyright © 2016 Xiaodi Wu. All rights reserved.
//

func pip(
  points: (x: [Float], y: [Float]),
  polygon vertices: [(Float, Float)]
) -> [Float] {
  let x = points.x
  let y = points.y
  let vertexCount = vertices.count
  // Vertex coordinates
  let vx = vertices.map { $0.0 }
  let vy = vertices.map { $0.1 }
  // Bounds
  let bx = (vx.min() ?? -Float.infinity, vx.max() ?? Float.infinity)
  let by = (vy.min() ?? -Float.infinity, vy.max() ?? Float.infinity)

  var result = [Float](repeating: 0, count: x.count)
  outer: for idx in 0..<x.count {
    // Coordinates of point to be interrogated
    let xi = x[idx], yi = y[idx]

    // First, check bounds
    if xi < bx.0 || xi > bx.1 || yi < by.0 || yi > by.1 {
      result[idx] = 0
      continue outer
    }

    var skippedVertices = 0
    var isFirstOffAxisVertexFound = false
    var firstOffAxisTest = false
    var skippedVerticesBeforeFirstOffAxisVertex = 0
    var firstOffAxisAdditionalTest = false
    var intersections = 0

    // Previous vertex coordinates minus coordinates of point to be
    // interrogated: initialize using last vertex
    var px = vx[vertexCount - 1] - xi, py = vy[vertexCount - 1] - yi
    inner: for i in 0..<vertexCount {
      let cx = vx[i] - xi, cy = vy[i] - yi
      // Current vertex coordinates minus coordinates of point to be
      // interrogated
      let pxcy = px * cy, cxpy = cx * py
      let test = (cy < 0.0) != (py < 0.0)

      // Check collinearity; gives a false negative if (`px`, `py`) or
      // (`cx`, `cy`) is at the origin, but that case is handled below
      if test && (pxcy == cxpy) {
        // It's already the case that `r[idx] == 1`
        continue outer
      }

      if cy == 0.0 {
        if cx < 0.0 {
          skippedVertices -= 1
          continue inner
        }
        if cx > 0.0 {
          skippedVertices += vertexCount
          continue inner
        }
        // `cx == 0.0`
        // It's already the case that `result[idx] == 1`
        continue outer
      }

      let additionalTest = (cy > py) ? (pxcy > cxpy) : (pxcy < cxpy)

      if !isFirstOffAxisVertexFound {
        // Defer incrementing or decrementing `intersections` for the first
        // off-axis vertex we find until we know if we've got to take into
        // account any skipped vertices at the end of the array
        isFirstOffAxisVertexFound = true
        firstOffAxisTest = test
        skippedVerticesBeforeFirstOffAxisVertex = skippedVertices
        firstOffAxisAdditionalTest = additionalTest
      } else if test {
        if skippedVertices > 0 || (skippedVertices == 0 && additionalTest) {
          intersections += 1
        }
      }
      skippedVertices = 0
      px = cx
      py = cy
    }
    if !isFirstOffAxisVertexFound {
      result[idx] = 0
      continue outer
    }
    // We've deliberately deferred incrementing or decrementing
    // `intersections` for the first off-axis vertex until now
    if firstOffAxisTest {
      skippedVertices += skippedVerticesBeforeFirstOffAxisVertex
      if skippedVertices > 0 ||
        (skippedVertices == 0 && firstOffAxisAdditionalTest) {
        intersections += 1
      }
    }
    // It's an even-odd algorithm, after all...
    result[idx] = Float(intersections % 2)
  }
  return result
}
