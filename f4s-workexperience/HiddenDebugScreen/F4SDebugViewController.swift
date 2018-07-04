//
//  F4SDebugViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 05/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import KeychainSwift

class F4SDebugViewController: UIViewController {
    
    static var outputUrl: URL?
    
    @IBOutlet weak var viewLogButton: UIButton!
    
    @IBOutlet weak var featureSwitchesButton: UIButton!
    @IBAction func featureSwitchesButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var returnToWorkfinder: UIButton!
    
    @IBAction func returnToWorkfinderButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
    }
    
   
    @IBAction func removeSettings(_ sender: Any) {
        
        let alert = UIAlertController(title: "Remove data and settings", message: "Remove all of Workfinder's data and settings from this device?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            
        }

        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (removeAction) in
            let keychain = KeychainSwift()
            let userUuidKey = UserDefaultsKeys.userUuid
            keychain.clear()
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
            let alert = UIAlertController(title: "Workfinder settings have been removed", message: "The app will now close. The next time you test it, the app should behave as if it were a first time install on a pristine device", preferredStyle: .alert)
            self.present(alert, animated: true, completion: {
                fatalError()
            })
        }
        alert.addAction(cancelAction)
        alert.addAction(removeAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func applyStyle() {
        F4SButtonStyler.apply(style: .primary, button: viewLogButton)
        F4SButtonStyler.apply(style: .secondary, button: returnToWorkfinder)
        F4SButtonStyler.apply(style: .secondary, button: featureSwitchesButton)
        
        F4SBackgroundViewStyler.apply(style: .standardPageBackground, backgroundView: self.view)
    }
}
