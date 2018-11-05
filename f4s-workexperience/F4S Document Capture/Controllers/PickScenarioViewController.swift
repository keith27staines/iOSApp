//
//  PickScenarioViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 29/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class PickScenarioViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? F4SDCAddDocumentsViewController {
            if segue.identifier == "show1" {
                vc.documentTypes = ["CV"]
                vc.mode = .businessLeaderRequest
            }
            if segue.identifier == "show3" {
                vc.documentTypes = ["CV","Swim cert","Sewing badge"]
                vc.mode = .applyWorkflow
            }
        }
    }

}
