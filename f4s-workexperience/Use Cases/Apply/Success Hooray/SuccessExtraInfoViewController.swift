//
//  SuccessExtraInfoViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 10/01/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import UIKit
import WorkfinderCommon

class SuccessExtraInfoViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timelineButton: UIButton!
    @IBOutlet weak var viewMapButton: UIButton!
    @IBOutlet weak var successLabel: UILabel!

    @IBOutlet weak var centerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerView.backgroundColor = UIColor.white
        centerView.layer.cornerRadius = 8
        centerView.layer.masksToBounds = true
        applyStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        F4SUserStatusService.shared.beginStatusUpdate()
    }
}

// MARK: - UI Setup
extension SuccessExtraInfoViewController {
    
    func applyStyle() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: timelineButton)
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: viewMapButton)
    }
}

// MARK: - User Interaction
extension SuccessExtraInfoViewController {
    
    @IBAction func timelineButtonTouched(_: UIButton) {
        navigationController?.popToRootViewController(animated: true)
        TabBarCoordinator.sharedInstance!.rewindAndNavigateToTimeline(from: self, show: nil)
    }
    
    @IBAction func viewMapButtonTouched(_: UIButton) {
        navigationController?.popToRootViewController(animated: true)
        //TabBarCoordinator.sharedInstance.popToTab(.map)
        TabBarCoordinator.sharedInstance!.rewindAndNavigateToMap(from: self)
    }
}
