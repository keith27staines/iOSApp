//
//  StringExtensions.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 09/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

extension String {
    var dehyphenated: String {
        return self.replacingOccurrences(of: "-", with: "")
    }
    
    func htmlDecode() -> String {
        return self
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}
