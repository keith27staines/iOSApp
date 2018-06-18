//
//  F4SAsynchronousOperation.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 17/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

/// A thread-safe implementation of an asynchronous operation, based on the best ideas I could find from various sources. This class is a good and safe choice for wrapping asynchronous network calls
open class AsynchronousOperation: Operation {
    
    // MARK: - Foundation.Operation
    // State machine interface
    open         override var isReady:        Bool { return state == .ready && super.isReady }
    public final override var isExecuting:    Bool { return state == .executing }
    public final override var isFinished:     Bool { return state == .finished }
    public final override var isAsynchronous: Bool { return true }
    
    public final override func start() {
        guard isReady else { return }
        state = .executing
        main()
    }
    
    /// Subclasses must override main because this where they should perform their own work. Subclasses must NOT call `super` and the default implementation of this function throws an exception to prevent this. As their first action, overrides should set `state` to executing, and as their final action, they should set `state` to finished
    open override func main() {
        // As as override's first action, it should set `state` to executing
        // state = .executing
        
        // And do not call super...
        fatalError("Subclasses must implement `main`.")
        
        // As as override's final action, it should set `state` to finished
        // state = .finished
    }
    
    /// Call this function to cancel an operation that is currently ready or executing
    public final override func cancel() {
        state = .finished
    }
    
    // MARK:- Private implementation
    
    /// State for this operation
    @objc private enum OperationState: Int {
        case ready
        case executing
        case finished
    }
    
    /// Concurrent queue for synchronizing access to `state`. This is what used to make this implementation thread-safe
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".rw.state", attributes: .concurrent)
    
    /// Private backing stored property for `state`.
    private var rawState: OperationState = .ready
    
    /// The state of the operation protected by an isolation queue to ensure thread safety
    @objc private dynamic var state: OperationState {
        get { return stateQueue.sync { rawState } }
        // Writes are performed as barriers so that all reads that are initiated before them are completed first, and no further reads (or writes) are permitted until this write is complete
        set { stateQueue.sync(flags: .barrier) { rawState = newValue } }
    }
    
    // MARK: - KVN for dependent properties
    @objc private dynamic class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return [#keyPath(state)]
    }
    
    @objc private dynamic class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return [#keyPath(state)]
    }
    
    @objc private dynamic class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return [#keyPath(state)]
    }
}
