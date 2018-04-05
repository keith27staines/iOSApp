//
//  F4SPageHeaderView.swift
//  HoursPicker2
//
//  Created by Keith Dev on 27/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SPageHeaderView: UIView {

    var angleDown: Bool = true
    var splashColor: UIColor = UIColor.blue
    var slopeUp: Bool = true
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let path = slopeUp ? pathSlopingUp() : pathSlopingDown()
        context?.addPath(path)
        context?.setFillColor(splashColor.cgColor)
        context?.fillPath()
    }
    
    func pathSlopingDown() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.size.height/5))
        path.closeSubpath()
        return path
    }
    
    func pathSlopingUp() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height/5))
        path.addLine(to: CGPoint(x: 0, y: bounds.size.height))
        path.closeSubpath()
        return path
    }


}
