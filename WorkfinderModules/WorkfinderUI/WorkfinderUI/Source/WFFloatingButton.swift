//
//  WFFloatingButton.swift
//  WorkfinderUI
//
//  Created by Keith on 16/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit

public final class WFFloatingButton: UIButton {

    private var shadowLayer: CAShapeLayer?

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard shadowLayer == nil else { return }
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: frame.height/2).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.shadowColor = UIColor.darkGray.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        shadowLayer.shadowOpacity = 0.15
        shadowLayer.shadowRadius = 2
        layer.insertSublayer(shadowLayer, at: 0)
        self.shadowLayer = shadowLayer
    }

}
