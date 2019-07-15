//
//  F4SForceAppUpdateViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 13/12/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon

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
    
    @IBOutlet weak var updateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 26, green: 168, blue: 76)
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: updateButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
