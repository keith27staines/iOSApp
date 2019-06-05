//
//  UITableView+Extensions.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/09/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public extension UITableView {
    
    func renderAllContentToImage() ->UIImage {
        let originalSize = self.frame.size
        var newSize = sizeThatFits(CGSize(width: originalSize.width, height: CGFloat.infinity))
        newSize.height *= 1.5
        frame = CGRect(origin: frame.origin, size: newSize)
        layoutSubviews()
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()!
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        frame = CGRect(origin: frame.origin, size: originalSize)
        return image ?? UIImage()
    }
}
