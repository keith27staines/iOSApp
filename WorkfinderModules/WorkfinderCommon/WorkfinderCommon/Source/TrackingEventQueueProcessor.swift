//
//  TrackingEventQueueProcessor.swift
//  WorkfinderCommon
//
//  Created by Keith Staines on 26/01/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

public class TrackingEventQueueProcessor {
    
    let eventQueue: TrackingEventQueue
    let isolation = DispatchQueue.init(label: "isolation")
    let timer: RepeatingTimerProtocol
    
    public func startProcessing() { timer.resume() }
    public func stopProcessing() { timer.suspend() }
    var itemHandler: ((TrackingEventType) -> Void)?
    
    public init(eventQueue: TrackingEventQueue, timer: RepeatingTimerProtocol, itemHandler: @escaping (TrackingEventType) -> Void) {
        self.eventQueue = eventQueue
        self.timer = RepeatingTimer(timeInterval: 1.001)
        timer.eventHandler = { [weak self] in
            guard let self = self, let event = eventQueue.dequeue() else { return }
            self.itemHandler?(event)
        }
    }
}


public protocol RepeatingTimerProtocol: AnyObject {
    var eventHandler: (() -> Void)? { get set }
    func resume()
    func suspend()
    
}

/// A "crash-proof" wrapper for GCD's DispatchSourceTimer
class RepeatingTimer: RepeatingTimerProtocol {
    
    let timeInterval: TimeInterval
    private(set) var state: State = .suspended
    var eventHandler: (() -> Void)?
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    enum State {
        case suspended
        case resumed
    }
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    func resume() {
        if state == .resumed { return }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended { return }
        state = .suspended
        timer.suspend()
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
       /*
        If the timer is suspended, calling cancel without resuming
        triggers a crash. This is documented here
        https://forums.developer.apple.com/thread/15902
        */
        resume()
        eventHandler = nil
    }
}
