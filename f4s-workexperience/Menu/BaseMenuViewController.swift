//
//  BaseMenuController.swift
//  f4s-workexperience
//
//  Created by Freshbyte on 12/8/14.
//  Copyright (c) 2014 Freshbyte. All rights reserved.
//

import UIKit

class BaseMenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: Selector(("contentSizeDidChangeNotification:")), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    private func contentSizeDidChangeNotification(notification: NSNotification) {
        if let userInfo: NSDictionary = notification.userInfo as NSDictionary? {
            self.contentSizeDidChange(size: userInfo[UIContentSizeCategory.newValueUserInfoKey] as! String)
        }
    }

    func contentSizeDidChange(size _: String) {
        // Implement in subclass
    }
}
