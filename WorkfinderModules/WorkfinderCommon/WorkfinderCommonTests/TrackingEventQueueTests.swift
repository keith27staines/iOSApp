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
    
    func test_loadFromPersistentStore() {
        mockPersistentStore.setValue(
            [
                TrackingEventType.first_use,
                TrackingEventType.app_open
            ],
            for: .trackingEvents
        )
        let sut = TrackingEventQueue(persistentStore: mockPersistentStore)
        XCTAssertEqual(sut.items, mockPersistentStore.value(key: .trackingEvents) as! [TrackingEventType])
    }
    
    func test_enqueue_dequeue() {
        sut.enqueue(item: .first_use)
        sut.enqueue(item: .app_open)
        XCTAssertEqual(sut.items.count, 2)
        XCTAssertEqual(sut.dequeue(), .first_use)
        XCTAssertEqual(sut.dequeue(), .app_open)
        XCTAssertEqual(sut.items.count, 0)
    }
    
    func test_writeToPersistentStore() {
        sut.enqueue(item: .first_use)
        sut.enqueue(item: .app_open)
        XCTAssertNil(mockPersistentStore.value(key: .trackingEvents))
        sut.writeToPersistentStore()
        XCTAssertEqual((mockPersistentStore.value(key: .trackingEvents) as? [TrackingEventType])?.count, 2)
    }
    
    func test_deinit() {
        sut.enqueue(item: .first_use)
        sut.enqueue(item: .app_open)
        XCTAssertNil(mockPersistentStore.value(key: .trackingEvents))
        sut = nil
        XCTAssertEqual((mockPersistentStore.value(key: .trackingEvents) as? [TrackingEventType])?.count, 2)
    }
    
}

class MockPersistentStore: LocalStorageProtocol {
    
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
