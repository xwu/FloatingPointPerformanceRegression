//
//  FloatingPointPerformanceRegressionTests.swift
//  FloatingPointPerformanceRegressionTests
//
//  Created by Xiaodi Wu on 8/1/16.
//  Copyright © 2016 Xiaodi Wu. All rights reserved.
//

import XCTest
@testable import FloatingPointPerformanceRegression

class FloatingPointPerformanceRegressionTests: XCTestCase {
  func testPointInPolygonPerformance() {
    let points = (
      x: [153 as Float, 160, 206, 207, 182, 245, 297, 230],
      y: [141 as Float, 205, 206, 167, 269, 199, 234, 324]
    )
    // Not pretty, but it's just a fixture.
    var repeatedPoints = (x: [Float](), y: [Float]())
    repeatedPoints.x.reserveCapacity(400_000)
    repeatedPoints.y.reserveCapacity(400_000)
    for _ in 0..<50_000 {
      repeatedPoints.x.append(contentsOf: points.x)
      repeatedPoints.y.append(contentsOf: points.y)
    }
    let polygon = [
      (163 as Float, 320 as Float), (203, 118), (301, 359), (103, 172),
      (388, 190), (187, 387), (292, 110)
    ]
    // This is an example of a performance test case.
    self.measure {
      let result = pip(points: repeatedPoints, polygon: polygon)
      // Make sure the compiler doesn't elide our computation.
      print(result[Int(arc4random_uniform(400_000))])
    }
  }
}
