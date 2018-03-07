//
//  F4SDebugViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 05/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SDebugViewController: UIViewController {
    
    static var outputUrl: URL?
    
    @IBOutlet weak var viewLogButton: UIButton!
    
    @IBOutlet weak var returnToWorkfinder: UIButton!
    
    @IBAction func returnToWorkfinderButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
    }
    
    func applyStyle() {
        F4SButtonStyler.apply(style: .primary, button: viewLogButton)
        F4SButtonStyler.apply(style: .secondary, button: returnToWorkfinder)
        F4SBackgroundViewStyler.apply(style: .standardPageBackground, backgroundView: self.view)
    }
}
