//
//  extensions.swift
//  WorkfinderMessagesUseCase
//
//  Created by Keith Dev on 13/09/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

extension NSObject {
    /// Use an NSLocking object as a mutex for a critical section of code
    func synchronized<L: NSLocking>(lockable: L, criticalSection: () -> Void) {
        lockable.lock()
        criticalSection()
        lockable.unlock()
    }
}
