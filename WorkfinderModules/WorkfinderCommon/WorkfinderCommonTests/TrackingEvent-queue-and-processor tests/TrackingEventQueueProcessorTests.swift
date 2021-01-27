//
//  TrackingEventQueueProcessorTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Staines on 26/01/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class TrackingEventQueueProcessorTests: XCTestCase {
    
    var persistentStore: MockPersistentStore!
    var timer: MockRepeatingTimer!
    var eventQueue: TrackingEventQueue!
    var sut: TrackingEventQueueProcessor!
    
    override func setUp() {
        persistentStore = MockPersistentStore()
        timer = MockRepeatingTimer()
        eventQueue = TrackingEventQueue(persistentStore: persistentStore)
        sut = TrackingEventQueueProcessor(
            eventQueue: eventQueue,
            timer: timer,
            itemHandler: {_ in }
        )
    }

    func test_queue_is_processed() {
        let inputEvents: [TrackingEventType] = [
            .first_use,
            .app_open,
            .onboarding_start,
            .onboarding_tap_just_get_started,
            .onboarding_convert
        ]
        inputEvents.forEach { (eventType) in
            eventQueue.enqueue(item: eventType)
        }
        var processedEvents = [TrackingEventType]()
        let expectations = [
            XCTestExpectation(description: "0"),
            XCTestExpectation(description: "1"),
            XCTestExpectation(description: "2"),
            XCTestExpectation(description: "3"),
            XCTestExpectation(description: "4")
        ]
        var index = 0
        sut.itemHandler = { eventType in
            processedEvents.append(eventType)
            expectations[index].fulfill()
            index += 1
        }
        (0...4).forEach { (_) in
            timer.fire()
        }
        wait(for: expectations, timeout: 1, enforceOrder: false)
        XCTAssertEqual(inputEvents, processedEvents)
    }

}

class MockRepeatingTimer: RepeatingTimerProtocol {
    
    var eventHandler: (() -> Void)?
    
    func resume() {}
    
    func suspend() {}
    
    func fire() {
        eventHandler?()
    }
}
