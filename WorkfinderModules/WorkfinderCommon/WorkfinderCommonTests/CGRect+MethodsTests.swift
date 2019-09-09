//
//  CGRect+MethodsTests.swift
//  F4SDataStructuresTests
//
//  Created by Keith Dev on 27/09/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class CGRectExtensiontests: XCTestCase {
    func testQuadrantRects() {
        let rect = CGRect(x: 0, y: 0, width: 2, height: 2)
        let expectedBL = CGRect(x: 0, y: 1, width: 1, height: 1)
        let expectedBR = CGRect(x: 1, y: 1, width: 1, height: 1)
        let expectedTL = CGRect(x: 0, y: 0, width: 1, height: 1)
        let expectedTR = CGRect(x: 1, y: 0, width: 1, height: 1)
        let quadrants = rect.quadrantRects()
        XCTAssertEqual(quadrants[.bottomLeft], expectedBL)
        XCTAssertEqual(quadrants[.bottomRight], expectedBR)
        XCTAssertEqual(quadrants[.topLeft], expectedTL)
        XCTAssertEqual(quadrants[.topRight], expectedTR)
    }
    func testBottomRightQuadrant() {
        let rect = CGRect(x: 0, y: 0, width: 2, height: 2)
        let expected = CGRect(x: 1, y: 1, width: 1, height: 1)
        let result = rect.bottomRightQuadrant()
        XCTAssertEqual(expected, result)
    }
    func testBottomLeftQuadrant() {
        let rect = CGRect(x: 0, y: 0, width: 2, height: 2)
        let expected = CGRect(x: 0, y: 1, width: 1, height: 1)
        let result = rect.bottomLeftQuadrant()
        XCTAssertEqual(expected, result)
    }
    func testTopRightQuadrant() {
        let rect = CGRect(x: 0, y: 0, width: 2, height: 2)
        let expected = CGRect(x: 1, y: 0, width: 1, height: 1)
        let result = rect.topRightQuadrant()
        XCTAssertEqual(expected, result)
    }
    func testToLeftQuadrant() {
        let rect = CGRect(x: 0, y: 0, width: 2, height: 2)
        let expected = CGRect(x: 0, y: 0, width: 1, height: 1)
        let result = rect.topLeftQuadrant()
        XCTAssertEqual(expected, result)
    }
    func testIsPointInsideBounds_CentreOfRect() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0.5, y: 0.5)
        XCTAssertTrue(rect.isPointInsideBounds(point))
    }
    func testIsPointInsideBounds_OnLeftEdge() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0, y: 0.5)
        XCTAssertFalse(rect.isPointInsideBounds(point))
    }
    func testIsPointInsideBounds_OnRightEdge() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 1, y: 0.5)
        XCTAssertFalse(rect.isPointInsideBounds(point))
    }
    func testIsPointInsideBounds_OnTopEdge() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0.5, y: 0)
        XCTAssertFalse(rect.isPointInsideBounds(point))
    }
    func testIsPointInsideBounds_OnBottomEdge() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0.5, y: 1)
        XCTAssertFalse(rect.isPointInsideBounds(point))
    }
    func testPointOnBoundaryLeftEdge() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0, y: 0.5)
        XCTAssertTrue(rect.isPointOnBounds(point))
    }
    func testPointOnBoundaryRightEdge() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 1, y: 0.5)
        XCTAssertTrue(rect.isPointOnBounds(point))
    }
    func testPointOnBoundaryTopEdge() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0.5, y: 0)
        XCTAssertTrue(rect.isPointOnBounds(point))
    }
    func testPointOnBoundaryBottomEdge() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0.5, y: 1)
        XCTAssertTrue(rect.isPointOnBounds(point))
    }
    func testPointIsStrictlyOutside_PointAtCentre() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0.5, y: 0.5)
        XCTAssertFalse(rect.isPointOutsideBounds(point))
    }
    func testPointIsStrictlyOutside_PointFarToLeft() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: -100, y: 0.5)
        XCTAssertTrue(rect.isPointOutsideBounds(point))
    }
    func testPointIsStrictlyOutside_PointFarToRight() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 100, y: 0.5)
        XCTAssertTrue(rect.isPointOutsideBounds(point))
    }
    func testPointIsStrictlyOutside_PointFarAbove() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0.5, y: -100)
        XCTAssertTrue(rect.isPointOutsideBounds(point))
    }
    func testPointIsStrictlyOutside_PointFarBelow() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0.5, y: 100)
        XCTAssertTrue(rect.isPointOutsideBounds(point))
    }
    func testPointIsStrictlyOutside_OnBoundary() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = CGPoint(x: 0, y: 0)
        XCTAssertFalse(rect.isPointOutsideBounds(point))
    }
}

















