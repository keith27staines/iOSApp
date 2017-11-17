//
//  GradientView.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 11/17/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeGradient()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeGradient()
    }

    func initializeGradient() {
        let colorTop = UIColor(netHex: Colors.blueGradientTop).cgColor
        let colorBottom = UIColor(netHex: Colors.BlueGradientBottom).cgColor
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [colorTop, colorBottom]
    }

}
