//
//  TrackingEventQueueTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Staines on 26/01/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class TrackingEventQueueTests: XCTestCase {
    var mockPersistentStore: MockPersistentStore!
    var sut: TrackingEventQueue!
    
    override func setUp() {
        mockPersistentStore = MockPersistentStore()
        sut = TrackingEventQueue(persistentStore: mockPersistentStore)
    }
    
    func test_items_load_from_persistent_store() {
        let events = [
            TrackingEventType.first_use,
            TrackingEventType.app_open
        ]
        let data = try! JSONEncoder().encode(events)
        mockPersistentStore.setValue(
            data,
            for: .trackingEvents
        )
        let sut = TrackingEventQueue(persistentStore: mockPersistentStore)
        XCTAssertEqual(sut.items, events)
    }
    
    func test_enqueue_dequeue() {
        XCTAssertFalse(sut.isDirty)
        sut.enqueue(item: .first_use)
        XCTAssertTrue(sut.isDirty)
        sut.enqueue(item: .app_open)
        XCTAssertTrue(sut.isDirty)
        XCTAssertEqual(sut.items.count, 2)
        XCTAssertEqual(sut.dequeue(), .first_use)
        XCTAssertEqual(sut.dequeue(), .app_open)
        XCTAssertEqual(sut.items.count, 0)
    }
    
    func test_writeToPersistentStore() {
        [TrackingEventType.first_use, TrackingEventType.app_open]
            .forEach { (event) in
            sut.enqueue(item: event)
        }
        let enqueuedItems = sut.items
        XCTAssertNil(mockPersistentStore.value(key: .trackingEvents))
        XCTAssertTrue(sut.isDirty)
        sut.writeToPersistentStore()
        XCTAssertFalse(sut.isDirty)
        sut.items = []
        let recoveredItems = sut.loadFromPersistentStore()
        XCTAssertEqual(recoveredItems, enqueuedItems)
    }
    
    func test_deinit() {
        sut.enqueue(item: .first_use)
        sut.enqueue(item: .app_open)
        XCTAssertNil(mockPersistentStore.value(key: .trackingEvents))
        sut = nil
        XCTAssertNotNil(mockPersistentStore.value(key: .trackingEvents))
    }
    
}

class MockPersistentStore: LocalStorageProtocol {
    func resetStore() {
        _store = [:]
    }
    
    
    var _store = [LocalStore.Key: Any]()
    
    func clear() {
        _store = [LocalStore.Key: Any]()
    }
    
    func value(key: LocalStore.Key) -> Any? {
        _store[key]
    }
    
    func setValue(_ value: Any?, for key: LocalStore.Key) {
        _store[key] = value
    }
}
