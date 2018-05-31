//
//  F4SForceAppUpdateViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 13/12/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import UIKit

class F4SForceAppUpdateViewController: UIViewController {
    
    let appStoreLink = "https://itunes.apple.com/gb/app/workfinder/id1196236194?mt=8"
    
    @IBAction func gotoAppStoreButtonPressed(_ sender: Any?) {
        
        
        /* First create a URL, then check whether there is an installed app that can
         open it on the device. */
        if let url = URL(string: appStoreLink), UIApplication.shared.canOpenURL(url) {
            // Attempt to open the URL.
            UIApplication.shared.open(url)

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
