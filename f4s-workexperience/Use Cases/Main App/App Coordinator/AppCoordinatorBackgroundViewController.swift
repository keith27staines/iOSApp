//
//  AppCoordinatorBackgroundViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 17/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import  UIKit
import WorkfinderCommon

class AppCoordinatorBackgroundViewController : UIViewController {
    override func viewDidLoad() {
        let background = skin!.navigationBarSkin.barTintColor
        view.backgroundColor = background.uiColor
        Skinner().apply(navigationBarSkin: skin?.navigationBarSkin, to: self)
    }
}
