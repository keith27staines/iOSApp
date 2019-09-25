//
//  F4SGrammar.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 05/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

struct F4SGrammar {
    static func list(_ strings: [String]) -> String? {
        switch strings.count {
        case 0: return nil
        case 1: return strings.first
        case 2: return "\(strings[0]) and \(strings[1])"
        case 3: return "\(strings[0]), \(strings[1]), and \(strings[2])"
        default:
            var allButLastTwo: String = strings.first!
            for i in 1...(strings.count - 3) {
                allButLastTwo += ", \(strings[i])"
            }
            let lastTwo: [String] = [String](strings.suffix(2))
            return list([allButLastTwo] + lastTwo)
        }
    }
}
