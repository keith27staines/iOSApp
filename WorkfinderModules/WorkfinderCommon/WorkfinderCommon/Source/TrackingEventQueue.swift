//
//  TrackingEventQueue.swift
//  WorkfinderCommon
//
//  Created by Keith Staines on 26/01/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

public class TrackingEventQueue {
    let persistentStore: LocalStorageProtocol
    var items = [TrackingEventType]()
    
    public func enqueue(item: TrackingEventType) {
        items.insert(item, at: 0)
    }
    
    public func dequeue() -> TrackingEventType? {
        items.removeLast()
    }
    
    public func writeToPersistentStore() {
        persistentStore.setValue(items, for: LocalStore.Key.trackingEvents)
    }
    
    public init(persistentStore: LocalStorageProtocol) {
        self.persistentStore = persistentStore
        loadFromPersistentStore()
    }
    
    private func loadFromPersistentStore() {
        items = persistentStore.value(key: LocalStore.Key.trackingEvents) as? [TrackingEventType] ?? []
    }
    
    deinit {
        writeToPersistentStore()
    }
    

}
