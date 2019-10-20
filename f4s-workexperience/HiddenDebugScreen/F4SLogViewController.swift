//
//  F4SLogViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 07/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon

class F4SLogViewController: UIViewController {

    @IBOutlet weak var logTextView: UITextView!
    weak var log: F4SAnalyticsAndDebugging?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        logTextView.text = log?.textCombiningHistoryAndSessionLog() ?? "Log unavailable because of a configuration error"
    }

    @IBAction func shareButtonPressed(_ sender: Any) {
        guard let text = logTextView.text, text.isEmpty == false else {
            return
        }
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }

}
