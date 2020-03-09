//
//  Common.swift
//  FileParser
//
//  Created by Keith Dev on 07/03/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import Foundation

public struct PinJson: Codable, Hashable {
    var companyUuid: String
    var lat: Double
    var lon: Double
    var tags: [String]
}
