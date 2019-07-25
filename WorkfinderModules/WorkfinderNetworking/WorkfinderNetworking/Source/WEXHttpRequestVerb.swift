//
//  WEXHttpRequestVerb.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 24/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public enum WEXHTTPRequestVerb {
    case get
    case put(Data)
    case patch(Data)
    case post(Data)
    case delete
    
    var name: String {
        switch self {
        case .get: return "GET"
        case .put(_): return "PUT"
        case .patch: return "PATCH"
        case .post: return "POST"
        case .delete: return "DELETE"
        }
    }
}
