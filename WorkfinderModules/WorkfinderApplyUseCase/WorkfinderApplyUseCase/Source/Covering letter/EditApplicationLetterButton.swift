//
//  EditApplicationLetterButton.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 23/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class EditApplicationLetterButton: UIButton {
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 35))
        let title = NSLocalizedString("Edit", comment: "")
        setTitle(title, for: UIControl.State.normal)
        layer.cornerRadius = 10
        layer.masksToBounds = true

        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.white, for: .highlighted)
        setTitle(title, for: UIControl.State.normal)
        titleEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        configureForLetterIsCompleteState(false)
    }
    
    func configureForLetterIsCompleteState(_ isComplete: Bool) {
        if isComplete {
            setBackgroundColor(color: WorkfinderColors.primaryColor, forUIControlState: .normal)
            setBackgroundColor(color: WorkfinderColors.primaryColor, forUIControlState: .highlighted)
        } else {
            setBackgroundColor(color: WorkfinderColors.warningNormal, forUIControlState: .normal)
            setBackgroundColor(color: WorkfinderColors.warningActive, forUIControlState: .highlighted)
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
