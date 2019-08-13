//
//  RotationAwareController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 03/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class RotationAwareNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.tintColor = UIColor(netHex: Colors.white)
        self.navigationBar.barTintColor = UIColor(netHex: Colors.black)
        
        self.toolbar.tintColor = UIColor(netHex: Colors.white)
        self.toolbar.barTintColor = UIColor(netHex: Colors.black)
    }
    
    open override var shouldAutorotate: Bool {
        let top = self.topViewController
        return (top?.shouldAutorotate)!
    }
}
