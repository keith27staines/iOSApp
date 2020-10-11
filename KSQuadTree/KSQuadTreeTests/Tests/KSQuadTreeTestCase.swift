
import XCTest
import KSGeometry
@testable import KSQuadTree

class KSQuadTreeTestCase: XCTestCase {
    
    func test_initalise() {
        let rect = KSRect(x: 10, y: 10, width: 10, height: 10)
        let sut = KSQuadTree(bounds: rect, depth: 5, maxItems: 2, parent: nil)
        XCTAssertEqual(sut.bounds, rect)
        XCTAssertEqual(sut.depth, 5)
        XCTAssertEqual(sut.maxItems, 2)
        XCTAssertNil(sut.parent)
    }
    
    func test_smallestSubtreeToContain_with_no_items() {
        let rect = KSRect(x: 10, y: 10, width: 10, height: 10)
        let sut = KSQuadTree(bounds: rect, depth: 5, maxItems: 2, parent: nil)
        XCTAssertNil(sut.smallestSubtreeToContain(elements: []))
    }
    
    func test_smallestSubtreeToContain_element() {
        let rect = KSRect(x: 0, y: 0, width: 4, height: 4)
        let sut = KSQuadTree(bounds: rect, depth: 5, maxItems: 2, parent: nil)
        let item1 = KSPoint(x:1,y:1)
        let item2 = KSPoint(x:3,y:1)
        let item3 = KSPoint(x:1,y:3)
        let item4 = KSPoint(x:3,y:3)
        try! sut.insert(item: item1)
        try! sut.insert(item: item2)
        try! sut.insert(item: item3)
        try! sut.insert(item: item4)
        XCTAssertEqual(sut.smallestSubtreeToContain(element: item1)?.bounds,rect.quadrantRects()[.bottomLeft])
        XCTAssertEqual(sut.smallestSubtreeToContain(element: item2)?.bounds,rect.quadrantRects()[.bottomRight])
        XCTAssertEqual(sut.smallestSubtreeToContain(element: item3)?.bounds,rect.quadrantRects()[.topLeft])
        XCTAssertEqual(sut.smallestSubtreeToContain(element: item4)?.bounds,rect.quadrantRects()[.topRight])
    }
    
    func test_smallestSubtreeToContain_elements() {
        let rect = KSRect(x: 0, y: 0, width: 4, height: 4)
        let sut = KSQuadTree(bounds: rect, depth: 5, maxItems: 2, parent: nil)
        let item1 = KSPoint(x:1,y:1)
        let item2 = KSPoint(x:3,y:1)
        let item3 = KSPoint(x:1,y:3)
        let item4 = KSPoint(x:3,y:3)
        try! sut.insert(item: item1)
        try! sut.insert(item: item2)
        try! sut.insert(item: item3)
        try! sut.insert(item: item4)
        XCTAssertNil(sut.smallestSubtreeToContain(elements:[]))
        XCTAssertEqual(sut.smallestSubtreeToContain(elements: [item1])?.bounds,rect.quadrantRects()[.bottomLeft])
        XCTAssertEqual(sut.smallestSubtreeToContain(elements: [item1,item2])?.bounds,rect)
    }
    
    func test_split_occurs_on_inserting_after_limit_reached() {
        let rect = KSRect(x: 0, y: 0, width: 2, height: 2)
        let item = KSPoint(x:0.5,y:0.5)
        let sut = KSQuadTree(bounds: rect, depth: 5, maxItems: 2, parent: nil)
        try! sut.insert(item: item)
        try! sut.insert(item: item)
        XCTAssertNil(sut.subtreeDictionary)
        XCTAssertEqual(sut.items.count, 2)
        try! sut.insert(item: item)
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertEqual(sut.subtreeDictionary?[.bottomLeft]?.items.count, 3)
    }
    
    func test_split_accumulates_none_quadrant_items() {
        let rect = KSRect(x: 0, y: 0, width: 2, height: 2)
        let nonQuadrantItem = KSPoint(x: 1, y: 1)
        let sut = KSQuadTree(bounds: rect, depth: 5, maxItems: 2, parent: nil)
        try! sut.insert(item: nonQuadrantItem) //
        try! sut.insert(item: nonQuadrantItem)
        try! sut.insert(item: nonQuadrantItem)
        let quadrantItem = KSPoint(x: 0.1, y: 0.1)
        try! sut.insert(item: quadrantItem)
        XCTAssertEqual(sut.items.count, 3)
        XCTAssertEqual(sut.subtreeDictionary?[.bottomLeft]?.items.count, 1)
    }
    
    func test_build_and_clear() {
        let rect = KSRect(x: 10, y: 10, width: 10, height: 10)
        let sut = KSQuadTree(bounds: rect, depth: 5, maxItems: 2, parent: nil)
        let item = KSPoint(x:11,y:11)
        try! sut.insert(item: item)
        try! sut.insert(item: item)
        // Add items up to the limit before this tree creates subtrees
        XCTAssertEqual(sut.items.count, 2)
        XCTAssertEqual(sut.count(), 2)
        XCTAssertNil(sut.subtreeDictionary)
        // Clear and ensure items and subtrees are empty
        sut.clear()
        XCTAssertEqual(sut.items.count,0)
        XCTAssertNil(sut.subtreeDictionary)
        // Add three items (one more than maxItems) to force subtrees to be created and items copied to them
        try! sut.insert(item: item)
        try! sut.insert(item: item)
        try! sut.insert(item: item)
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertEqual(sut.count(), 3)
        XCTAssertEqual(sut.subtreeDictionary!.count, 4)
        // Add one more item to ensure it goes into the existing subtrees and not the items collection
        try! sut.insert(item: item)
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertEqual(sut.count(), 4)
        XCTAssertEqual(sut.subtreeDictionary!.count, 4)
        // Clear and check both items and subtrees are empty
        sut.clear()
        XCTAssertEqual(sut.items.count,0)
        XCTAssertNil(sut.subtreeDictionary)
    }
    
    func testQuadrantForItemFarOutside() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let exteriorPoint = KSPoint(x: -1, y: 0)
        let quadrant = qt.quadrant(for: exteriorPoint)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.none)
    }
    func testQuadrantForItemOnLeftBoundary() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let boundaryPoint = KSPoint(x: 0, y: 0.5)
        let quadrant = qt.quadrant(for: boundaryPoint)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.none)
    }
    func testQuadrantForItemOnRightBoundary() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let boundaryPoint = KSPoint(x: 2, y: 0.5)
        let quadrant = qt.quadrant(for: boundaryPoint)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.none)
    }
    func testQuadrantForItemOnTopBoundary() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let boundaryPoint = KSPoint(x: 0.5, y: 0)
        let quadrant = qt.quadrant(for: boundaryPoint)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.none)
    }
    func testQuadrantForItemOnBottomBoundary() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let boundaryPoint = KSPoint(x: 0.5, y: 2)
        let quadrant = qt.quadrant(for: boundaryPoint)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.none)
    }
    func testQuadrantForItemOnHorizontalMidline() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let point = KSPoint(x: 0.5, y: 1)
        let quadrant = qt.quadrant(for: point)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.useOwnBounds)
    }
    func testQuadrantForItemOnVerticalMidline() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let point = KSPoint(x: 1, y: 0.5)
        let quadrant = qt.quadrant(for: point)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.useOwnBounds)
    }
    func testQuadrantForItemInTopLeftQuadrant() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let point = KSPoint(x: 0.5, y: 0.5)
        let quadrant = qt.quadrant(for: point)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.bottomLeft)
    }
    func testQuadrantForItemInTopRightQuadrant() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let point = KSPoint(x: 1.5, y: 0.5)
        let quadrant = qt.quadrant(for: point)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.bottomRight)
    }
    func testQuadrantForItemInBottomLeftQuadrant() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let point = KSPoint(x: 0.5, y: 1.5)
        let quadrant = qt.quadrant(for: point)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.topLeft)
    }
    func testQuadrantForItemInBottomRightQuadrant() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let point = KSPoint(x: 1.5, y: 1.5)
        let quadrant = qt.quadrant(for: point)
        XCTAssertEqual(quadrant, KSQuadrantAssignment.topRight)
    }
    func testInitQuadTreeSettingMaxItemsAndDepth() {
        let rect = KSRect(x: 0, y: 0, width: 2, height: 2)
        let qt = try! KSQuadTree(bounds: rect, items: nil, depth: 27, maxItems: 72)
        XCTAssertEqual(qt.depth, 27)
        XCTAssertEqual(qt.maxItems, 72)
    }
    func testInitQuadTreeWithItemOutsideBoundsThrows() {
        let rect = KSRect(x: 0, y: 0, width: 2, height: 2)
        let exteriorPoint = KSPoint(x: -1, y: 0)
        XCTAssertThrowsError(try KSQuadTree(bounds: rect, items: [exteriorPoint]))
    }
    func testInsertItemOutsideOfBoundsThrows() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let exteriorPoint = KSPoint(x: -1, y: 0)
        XCTAssertThrowsError(try qt.insert(item: exteriorPoint))
    }
    func testInsertItemOnBoundaryThrows() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let boundaryPoint = KSPoint(x: 0, y: 0)
        XCTAssertThrowsError(try qt.insert(item: boundaryPoint))
    }
    func testInsertItem() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let point = KSPoint(x: 0.5, y: 0.5)
        try! qt.insert(item: point)
        XCTAssertNil(qt.subtreeDictionary)
        XCTAssertEqual(qt.items.count, 1)
        XCTAssertEqual(qt.items[0].point, point)
    }
    func testInsertMaximumItemsBeforeSplitting() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let point = KSPoint(x: 0.5, y: 0.5)
        try! qt.insert(item: point)
        try! qt.insert(item: point)
        XCTAssertNil(qt.subtreeDictionary)
        XCTAssertEqual(qt.items.count, 2)
    }
    func testInsertOneMoreThanMaximumItemsDoesntCauseSplitIfAtDepth0() {
        let rect = KSRect(x: 0, y: 0, width: 2, height: 2)
        let qt = try! KSQuadTree(bounds: rect, items: nil, depth: 0, maxItems: 2)
        KSQuadTreeTestCase.addOneMoreThanMaxItems(qt: qt)
        XCTAssertNil(qt.subtreeDictionary)
        XCTAssertEqual(qt.items.count, 3)
        XCTAssertGreaterThan(qt.items.count, qt.maxItems)
    }
    func testInsertOneMoreThanMaximumItemsCausingSplit() {
        let qt = KSQuadTreeTestCase.createSplitSubtree()
        XCTAssertNotNil(qt.subtreeDictionary)
        XCTAssertEqual(qt.items.count, 0)
        XCTAssertEqual(qt.subtreeDictionary![.topLeft]!.items.count,0)
        XCTAssertEqual(qt.subtreeDictionary![.topRight]!.items.count,0)
        XCTAssertEqual(qt.subtreeDictionary![.bottomLeft]!.items.count,3)
        XCTAssertEqual(qt.subtreeDictionary![.bottomRight]!.items.count,0)
    }
    func testSubtreeDepth() {
        let qt = KSQuadTreeTestCase.createSplitSubtree()
        let topLevel = qt.depth
        let nextLevel = qt.subtreeDictionary![.topLeft]!.depth
        XCTAssertEqual(topLevel, nextLevel+1)
    }
    func testAddingItemToAlreadySplitTreeOnMidline() {
        let qt = KSQuadTreeTestCase.createSplitSubtree()
        let point = KSPoint(x: qt.bounds.midX, y: 0.5)
        try! qt.insert(item: point)
        XCTAssertTrue(qt.items.contains(where: { (item) -> Bool in
            return point == (item as? KSPoint)
        }))
    }
    func testRetrieveFromEmptyTree() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let items: [KSQuadTreeItem] = qt.retrieveAll()
        XCTAssertTrue(items.count == 0)
    }
    func testRetrieveFromNonSplitTree() {
        let qt = KSQuadTreeTestCase.createEmptyTree()
        let point = KSPoint(x: 0.5, y: 0.5)
        try! qt.insert(item: point)
        let items: [KSQuadTreeItem] = qt.retrieveAll()
        XCTAssertTrue(items.count == 1)
    }
    
    func testRetrieveWithExternalRect() {
        let qt = KSQuadTreeTestCase.createSplitSubtree()
        let externalRect = KSRect(x: -10, y: -10, width: 1, height: 1)
        XCTAssertTrue(qt.retrieveWithinRect(externalRect).count == 0)
    }
    func testRetrieveTopLeftWithBottomLeftQuadrantRectContainingAllItems() {
        let qt = KSQuadTreeTestCase.createSplitSubtree()
        let rect = qt.bounds.quadrantRects()[.topLeft]!
        XCTAssertEqual(qt.retrieveWithinRect(rect).count, 0)
    }
    func testRetrieveTopRightWithBottomLeftQuadrantRectContainingAllItems() {
        let qt = KSQuadTreeTestCase.createSplitSubtree()
        let rect = qt.bounds.quadrantRects()[.topRight]!
        XCTAssertEqual(qt.retrieveWithinRect(rect).count, 0)
    }
    func testRetrieveBottomWithBottomLeftQuadrantRectContainingAllItems() {
        let qt = KSQuadTreeTestCase.createSplitSubtree()
        let rect = qt.bounds.quadrantRects()[.bottomLeft]!
        XCTAssertEqual(qt.retrieveWithinRect(rect).count, 3)
    }
    func testRetrieveBottomRightWithBottomLeftQuadrantRectContainingAllItems() {
        let qt = KSQuadTreeTestCase.createSplitSubtree()
        let rect = qt.bounds.quadrantRects()[.bottomRight]!
        XCTAssertEqual(qt.retrieveWithinRect(rect).count, 0)
    }
    
    func test_couldContain_with_empty_array() {
        let rect = KSRect(x: 0, y: 0, width: 2, height: 2)
        let sut = KSQuadTree(bounds: rect)
        XCTAssertFalse(sut.couldContain(elements: []))
    }
    
    func testCouldContain_with_item_outside() {
        let rect = KSRect(x: 0, y: 0, width: 2, height: 2)
        let sut = KSQuadTree(bounds: rect)
        let outsideItem = KSPoint(x: -1, y: 0)
        XCTAssertFalse(sut.couldContain(elements: [outsideItem]))
    }
    
    func test_retrieveAll() {
        let sut = KSQuadTreeTestCase.createSplitSubtree()
        XCTAssertEqual(sut.retrieveAll().count, sut.retrieveWithinRect(sut.bounds).count)
    }
    
    func test_smallestSubtreeToContain_when_point_outside_bounds() {
        let sut = KSQuadTreeTestCase.createSplitSubtree()
        let point = KSPoint(x: -99999, y: -99999)
        XCTAssertNil(sut.smallestSubtreeToContain(elements: [point]))
    }
    
    func test_smallestSubtreeToContain_when_point_inside_bounds_but_not_inserted() {
        let sut = KSQuadTreeTestCase.createSplitSubtree()
        let point = KSPoint(x: 0.12345, y: 0.12345)
        XCTAssertNotNil(sut.smallestSubtreeToContain(elements: [point]))
    }
    
}

// MARK: helpers
extension KSQuadTreeTestCase {
    /// Creates an empty tree with depth = 2, maxItems = 2, bounds = KSRect(0,0,2,2)
    static func createEmptyTree() -> KSQuadTree {
        let rect = KSRect(x: 0, y: 0, width: 2, height: 2)
        let qt = try! KSQuadTree(bounds: rect, items: nil, depth: 2, maxItems: 2)
        XCTAssertNil(qt.subtreeDictionary)
        return qt
    }
    
    /// Creates a quadtree with depth of 2, maxItems = 2 with sufficient items to create a split
    static func createSplitSubtree() -> KSQuadTree {
        let qt = createEmptyTree()
        addOneMoreThanMaxItems(qt: qt)
        XCTAssertNotNil(qt.subtreeDictionary)
        return qt
    }
    
    /// Adds sufficient items to cause a split
    static func addOneMoreThanMaxItems(qt:KSQuadTree) {
        let point = KSPoint(x: qt.bounds.size.width/4.0, y: qt.bounds.size.height/4.0)
        for _ in 0...qt.maxItems {
            try! qt.insert(item: point)
        }
    }
}








