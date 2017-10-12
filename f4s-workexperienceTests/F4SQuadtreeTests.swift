//
//  F4SQuadtreeTests.swift
//  F4SDataStructuresTests
//
//  Created by Keith Dev on 27/09/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class F4SQuadtreeTests: XCTestCase {
    func testQuadrantForItemFarOutside() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let exteriorPoint = CGPoint(x: -1, y: 0)
        let item = F4SQuadtreeItem(point: exteriorPoint, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.none)
    }
    func testQuadrantForItemOnLeftBoundary() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let boundaryPoint = CGPoint(x: 0, y: 0.5)
        let item = F4SQuadtreeItem(point: boundaryPoint, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.none)
    }
    func testQuadrantForItemOnRightBoundary() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let boundaryPoint = CGPoint(x: 2, y: 0.5)
        let item = F4SQuadtreeItem(point: boundaryPoint, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.none)
    }
    func testQuadrantForItemOnTopBoundary() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let boundaryPoint = CGPoint(x: 0.5, y: 0)
        let item = F4SQuadtreeItem(point: boundaryPoint, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.none)
    }
    func testQuadrantForItemOnBottomBoundary() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let boundaryPoint = CGPoint(x: 0.5, y: 2)
        let item = F4SQuadtreeItem(point: boundaryPoint, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.none)
    }
    func testQuadrantForItemOnHorizontalMidline() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let point = CGPoint(x: 0.5, y: 1)
        let item = F4SQuadtreeItem(point: point, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.useOwnBounds)
    }
    func testQuadrantForItemOnVerticalMidline() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let point = CGPoint(x: 1, y: 0.5)
        let item = F4SQuadtreeItem(point: point, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.useOwnBounds)
    }
    func testQuadrantForItemInTopLeftQuadrant() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let point = CGPoint(x: 0.5, y: 0.5)
        let item = F4SQuadtreeItem(point: point, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.topLeft)
    }
    func testQuadrantForItemInTopRightQuadrant() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let point = CGPoint(x: 1.5, y: 0.5)
        let item = F4SQuadtreeItem(point: point, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.topRight)
    }
    func testQuadrantForItemInBottomLeftQuadrant() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let point = CGPoint(x: 0.5, y: 1.5)
        let item = F4SQuadtreeItem(point: point, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.bottomLeft)
    }
    func testQuadrantForItemInBottomRightQuadrant() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let point = CGPoint(x: 1.5, y: 1.5)
        let item = F4SQuadtreeItem(point: point, object: 1)
        let quadrant = qt.quadrant(for: item)
        XCTAssertEqual(quadrant, F4SQuadtreeQuadrant.bottomRight)
    }
    func testInitQuadTreeSettingMaxItemsAndDepth() {
        let rect = CGRect(x: 0, y: 0, width: 2, height: 2)
        let qt = try! F4SPointQuadtree(bounds: rect, items: nil, depth: 27, maxItems: 72)
        XCTAssertEqual(qt.depth, 27)
        XCTAssertEqual(qt.maxItems, 72)
    }
    func testInitQuadTreeWithItemOutsideBoundsThrows() {
        let rect = CGRect(x: 0, y: 0, width: 2, height: 2)
        let exteriorPoint = CGPoint(x: -1, y: 0)
        let item = F4SQuadtreeItem(point: exteriorPoint, object: 1)
        XCTAssertThrowsError(try F4SPointQuadtree(bounds: rect, items: [item]))
    }
    func testInsertItemOutsideOfBoundsThrows() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let exteriorPoint = CGPoint(x: -1, y: 0)
        let item = F4SQuadtreeItem(point: exteriorPoint, object: 1)
        XCTAssertThrowsError(try qt.insert(item: item))
    }
    func testInsertItemOnBoundaryThrows() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let boundaryPoint = CGPoint(x: 0, y: 0)
        let item = F4SQuadtreeItem(point: boundaryPoint, object: 1)
        XCTAssertThrowsError(try qt.insert(item: item))
    }
    func testInsertItem() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let point = CGPoint(x: 0.5, y: 0.5)
        let item = F4SQuadtreeItem(point: point, object: 1)
        try! qt.insert(item: item)
        XCTAssertNil(qt.subtreeDictionary)
        XCTAssertEqual(qt.items.count, 1)
        XCTAssertEqual(qt.items[0].point, point)
    }
    func testInsertMaximumItemsBeforeSplitting() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let point = CGPoint(x: 0.5, y: 0.5)
        let item1 = F4SQuadtreeItem(point: point, object: 1)
        let item2 = F4SQuadtreeItem(point: point, object: 2)
        try! qt.insert(item: item1)
        try! qt.insert(item: item2)
        XCTAssertNil(qt.subtreeDictionary)
        XCTAssertEqual(qt.items.count, 2)
    }
    func testInsertOneMoreThanMaximumItemsDoesntCauseSplitIfAtDepth0() {
        let rect = CGRect(x: 0, y: 0, width: 2, height: 2)
        let qt = try! F4SPointQuadtree(bounds: rect, items: nil, depth: 0, maxItems: 2)
        F4SQuadtreeTests.addOneMoreThanMaxItems(qt: qt)
        XCTAssertNil(qt.subtreeDictionary)
        XCTAssertEqual(qt.items.count, 3)
        XCTAssertGreaterThan(qt.items.count, qt.maxItems)
    }
    func testInsertOneMoreThanMaximumItemsCausingSplit() {
        let qt = F4SQuadtreeTests.createSplitSubtree()
        XCTAssertNotNil(qt.subtreeDictionary)
        XCTAssertEqual(qt.items.count, 0)
        XCTAssertEqual(qt.subtreeDictionary![.topLeft]!.items.count,3)
        XCTAssertEqual(qt.subtreeDictionary![.topRight]!.items.count,0)
        XCTAssertEqual(qt.subtreeDictionary![.bottomLeft]!.items.count,0)
        XCTAssertEqual(qt.subtreeDictionary![.bottomLeft]!.items.count,0)
    }
    func testSubtreeDepth() {
        let qt = F4SQuadtreeTests.createSplitSubtree()
        let topLevel = qt.depth
        let nextLevel = qt.subtreeDictionary![.topLeft]!.depth
        XCTAssertEqual(topLevel, nextLevel+1)
    }
    func testAddingItemToAlreadySplitTreeOnMidline() {
        let qt = F4SQuadtreeTests.createSplitSubtree()
        let point = CGPoint(x: qt.bounds.midX, y: 0.5)
        let itemX = F4SQuadtreeItem(point: point, object: "X")
        try! qt.insert(item: itemX)
        XCTAssertTrue(qt.items.contains(where: { (item) -> Bool in
            guard let x = item.object as? String, x == "X" else {
                return false
            }
            return true
        }))
    }
    func testRetrieveFromEmptyTree() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let items: [F4SQuadtreeElement] = qt.retrieveAll()
        XCTAssertTrue(items.count == 0)
    }
    func testRetrieveFromNonSplitTree() {
        let qt = F4SQuadtreeTests.createEmptyTree()
        let point = CGPoint(x: 0.5, y: 0.5)
        let item = F4SQuadtreeItem(point: point, object: 1)
        try! qt.insert(item: item)
        let items: [F4SQuadtreeElement] = qt.retrieveAll()
        XCTAssertTrue(items.count == 1)
    }
    
    func testRetrieveWithExternalRect() {
        let qt = F4SQuadtreeTests.createSplitSubtree()
        let externalRect = CGRect(x: -10, y: -10, width: 1, height: 1)
        XCTAssertTrue(qt.retrieveWithinRect(externalRect).count == 0)
    }
    func testRetrieveTopeLeftWithTopLeftQuadrantRectContainingAllItems() {
        let qt = F4SQuadtreeTests.createSplitSubtree()
        let topLeft = CGRect(x: 0, y: 0, width: 1, height: 1)
        XCTAssertEqual(qt.retrieveWithinRect(topLeft).count, qt.retrieveAll().count)
    }
    func testRetrieveTopRightWithTopLeftQuadrantRectContainingAllItems() {
        let qt = F4SQuadtreeTests.createSplitSubtree()
        let topRight = CGRect(x: 1, y: 0, width: 1, height: 1)
        XCTAssertEqual(qt.retrieveWithinRect(topRight).count, 0)
    }
    func testRetrieveTopLeftEmptyQuadrantWithTopLeftQuadrantRectContainingAllItems() {
        let qt = F4SQuadtreeTests.createSplitSubtree()
        let topLeftEmpty = CGRect(x: 0, y: 0, width: 0.1, height: 0.1)
        XCTAssertEqual(qt.retrieveWithinRect(topLeftEmpty).count, 0)
    }
    func testRetrieveTopLeftPopulatedSubquadrantQuadrantWithTopLeftQuadrantRectContainingAllItems() {
        let qt = F4SQuadtreeTests.createSplitSubtree()
        let topLeftPopulated = CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2)
        XCTAssertEqual(qt.retrieveWithinRect(topLeftPopulated).count, qt.retrieveAll().count)
    }
}

// MARK: helpers
extension F4SQuadtreeTests {
    /// Creates an empty tree with depth = 2, maxItems = 2, bounds = CGRect(0,0,2,2)
    static func createEmptyTree() -> F4SPointQuadtreeProtocol {
        let rect = CGRect(x: 0, y: 0, width: 2, height: 2)
        let qt = try! F4SPointQuadtree(bounds: rect, items: nil, depth: 2, maxItems: 2)
        XCTAssertNil(qt.subtreeDictionary)
        return qt
    }
    
    /// Creates a quadtree with depth of 2, maxItems = 2 with sufficient items to create a split
    static func createSplitSubtree() -> F4SPointQuadtreeProtocol {
        let qt = createEmptyTree()
        addOneMoreThanMaxItems(qt: qt)
        XCTAssertNotNil(qt.subtreeDictionary)
        return qt
    }
    
    /// Adds sufficient items to cause a split
    static func addOneMoreThanMaxItems(qt:F4SPointQuadtreeProtocol) {
        let point = CGPoint(x: qt.bounds.width/4.0, y: qt.bounds.height/4.0)
        for i in 0...qt.maxItems {
            let item = F4SQuadtreeItem(point: point, object: i)
            try! qt.insert(item: item)
        }
    }
}








