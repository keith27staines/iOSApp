//
//  TrackingEventQueueProcessor.swift
//  WorkfinderCommon
//
//  Created by Keith Staines on 26/01/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

public class TrackingEventQueueProcessor {
    
    let isolation = DispatchQueue(label: "TrackingEventQueueProcessor.isolation")
    let eventQueue: TrackingEventQueue
    var itemHandler: ((TrackingEventType) -> Void)?
    let interval: TimeInterval
    public private(set)var isSuspended: Bool = true
    
    public init(
        eventQueue: TrackingEventQueue,
        interval: TimeInterval,
        itemHandler: @escaping (TrackingEventType) -> Void
    ) {
        self.eventQueue = eventQueue
        self.itemHandler = itemHandler
        self.interval = interval
    }
    
    public func enqueueEventType(_ event: TrackingEventType) {
        isolation.async { [weak self] in
            self?.eventQueue.enqueue(item: event)
        }
    }
    
    public func suspend() {
        isolation.async { [weak self] in
            self?.isSuspended = true
        }
    }
    
    public func resume() {
        isolation.async { [weak self] in
            self?.isSuspended = false
            self?.pollUntilPaused()
        }
    }
    
    private func pollUntilPaused() {
        isolation.asyncAfter(deadline: .now() + interval) { [weak self] in
            guard let self = self, self.isSuspended == false else { return }
            guard let event = self.eventQueue.dequeue() else {
                // print("TEQ is empty at \(Date())")
                self.pollUntilPaused()
                return
            }
            print("TEQP dequeued \(event) at \(Date())")
            self.itemHandler?(event)
            self.pollUntilPaused()
        }
    }
}
