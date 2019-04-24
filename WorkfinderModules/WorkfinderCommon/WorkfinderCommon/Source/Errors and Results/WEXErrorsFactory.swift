//
//  WEXErrorsFactory.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 16/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public protocol WEXError : Error {
    var nsError: NSError? { get }
    var localizedDescription: String { get }
    var response: HTTPURLResponse? { get }
    var code: Int? { get }
    var attempting: String? { get }
    var retry: Bool { get }
    var data: Data? { get }
}

/// factory methods are implemented in extensions
public struct WEXErrorsFactory {}
