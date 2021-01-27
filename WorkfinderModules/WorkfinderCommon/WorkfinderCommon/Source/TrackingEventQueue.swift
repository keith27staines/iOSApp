//
//  TrackingEventQueue.swift
//  WorkfinderCommon
//
//  Created by Keith Staines on 26/01/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

public class TrackingEventQueue {
    let isolation = DispatchQueue(label: "TrackingEventQueue.isolation")
    let persistentStore: LocalStorageProtocol
    var items = [TrackingEventType]()
    private var isDirty: Bool = false
    
    public func enqueue(item: TrackingEventType) {
        items.insert(item, at: 0)
        isDirty = true
    }
    
    public func dequeue() -> TrackingEventType? {
        isDirty = true
        return items.isEmpty ? nil : items.removeLast()
    }
    
    private func loadFromPersistentStore() -> [TrackingEventType] {
        var persistedItems = [TrackingEventType]()
        guard let data = persistentStore.value(key: LocalStore.Key.trackingEvents) as? Data else {
            return persistedItems
        }
        do {
            persistedItems = try JSONDecoder().decode([TrackingEventType].self, from: data)
            isDirty = false
            print("TEQ did load \(persistedItems.count) from persistent store at \(Date())")
        } catch {
            print("TEQ failed to load data from persistent store at \(Date())")
        }
        return persistedItems
    }
    
    @objc public func writeToPersistentStore() {
        guard isDirty else { return }
        do {
            let data = try JSONEncoder().encode(items)
            persistentStore.setValue(data, for: LocalStore.Key.trackingEvents)
            isDirty = false
            print("TEQ did write \(items.count) to persistent store at \(Date())")
        } catch {
            print("TEQ did FAIL to write \(items.count) to persistent store at \(Date())")
        }
    }
    
    public init(persistentStore: LocalStorageProtocol) {
        self.persistentStore = persistentStore
        NotificationCenter.default.addObserver(self, selector: #selector(writeToPersistentStore), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(writeToPersistentStore), name: UIApplication.willTerminateNotification, object: nil)
        items = loadFromPersistentStore() + items
    }
    
    deinit {
        writeToPersistentStore()
    }
    

}
