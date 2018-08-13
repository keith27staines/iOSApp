//
//  CutomClusterIconGenerator.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 23/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreGraphics

class CustomClusterIconGenerator: NSObject, GMUClusterIconGenerator {
    
    var color: UIColor = UIColor.red
    
    convenience init(color: UIColor) {
        self.init()
        self.color = color
    }

    func icon(forSize size: UInt) -> UIImage! {

        let font = UIFont.boldSystemFont(ofSize: 17)

        let text = String(size)
        let attributedString = NSAttributedString(string: text, attributes: [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: UIColor.white,
        ])
        let textSize = attributedString.size()
        let rect = CGRect(x: 0, y: 0, width: 60, height: 60)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        let clusterColor = UIColor(netHex: 0x40AF50)
        ctx?.setFillColor(clusterColor.cgColor)
        ctx?.fillEllipse(in: rect)
        ctx?.restoreGState()

        let textRect = rect.insetBy(dx: (rect.size.width - textSize.width) / 2,
                                    dy: (rect.size.height - textSize.height) / 2)
        attributedString.draw(in: textRect)
        let clusterIcon = UIGraphicsGetImageFromCurrentImageContext()
        return clusterIcon
    }
}
