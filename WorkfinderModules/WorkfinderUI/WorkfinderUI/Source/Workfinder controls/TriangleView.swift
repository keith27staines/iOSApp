//
//  TriangleView.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 25/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class TriangleView: UIView {

    override func draw(_: CGRect) {

        // Get Height and Width
        let layerHeight = layer.frame.height
        let layerWidth = layer.frame.width

        // Create Path
        let bezierPath = UIBezierPath()

        // Draw Points
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: layerWidth / 2, y: layerHeight))
        bezierPath.addLine(to: CGPoint(x: layerWidth, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.close()

        // Apply Color
        UIColor.white.setFill()
        bezierPath.fill()

        // Mask to Path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        layer.mask = shapeLayer
    }
}
