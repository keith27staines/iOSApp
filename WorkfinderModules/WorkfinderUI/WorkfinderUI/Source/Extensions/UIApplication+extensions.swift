//
//  UIApplication+extensions.swift
//  WorkfinderUI
//
//  Created by Keith on 27/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit

public extension UIApplication {
    var firstKeyWindow: UIWindow? {
        UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
