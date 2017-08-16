//
//  MenuHelper.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import UIKit

class MenuHelper: NSObject {

    var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        super.init()
        self.navigationController = navigationController
    }

    func setupLeftMenuButton() {
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(leftDrawerButtonPress(sender:)))
        self.navigationController?.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
    }

    func openMenuButton() {
        self.navigationController?.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }

    // MARK: - Button Handlers

    func leftDrawerButtonPress(sender _: AnyObject?) {
        self.navigationController?.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }

    func isMenuVisible() -> Int {
        if (self.navigationController?.evo_drawerController?.visibleLeftDrawerWidth)! > CGFloat(0) {
            return 1
        }
        return 0
    }
}
