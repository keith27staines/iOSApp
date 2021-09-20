//
//  WFCapsuleHeightClass.swift
//  WorkfinderUI
//
//  Created by Keith on 08/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

public enum WFCapsuleHeightClass {
    case small
    case larger
    case clickable
    case large
}

public extension WFCapsuleHeightClass {
    var height: CGFloat {
        switch self {
        case .small: return 24
        case .larger: return 32
        case .clickable: return 44
        case .large: return 50
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .small: return 12
        case .larger: return 14
        case .clickable: return 16
        case .large: return 20
        }
    }
}
