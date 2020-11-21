//
//  TabBarViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 15/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI

class TabBarViewController: UITabBarController {
    
    public init() { super.init(nibName: nil, bundle: nil) }
    
    public required init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    func configureTimelineTabBarWithCount(count: Int? = 0) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let tabBarItem = strongSelf.viewControllers!.first!.tabBarItem!
            if let count = count, count > 0 {
                tabBarItem.badgeValue = String(count)
            } else {
                tabBarItem.badgeValue = nil
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UI Setup
    fileprivate func configureTabBar() {
        Skinner().apply(tabBarSkin: skin?.tabBarSkin, to: self)
        tabBar.unselectedItemTintColor = UIColor.lightGray
        tabBar.tintColor = WorkfinderColors.primaryColor
    }

    override func viewWillAppear(_ animation: Bool) {
        super.viewWillAppear(animation)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeMenuCustomGesture()
    }
}

// MARK: - menu actions
extension TabBarViewController {
    func addMenuCustomGesture() {
        self.evo_drawerController?.gestureShouldRecognizeTouchBlock = menuGestureShouldRecognizeTouch
    }

    func removeMenuCustomGesture() {
        self.evo_drawerController?.gestureShouldRecognizeTouchBlock = nil
    }

    func menuGestureShouldRecognizeTouch(drawerController _: DrawerController, gestureRecognizer _: UIGestureRecognizer, touch _: UITouch) -> Bool {
        return false
    }
}
