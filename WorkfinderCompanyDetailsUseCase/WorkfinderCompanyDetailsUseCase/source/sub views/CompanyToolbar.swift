//
//  CompanyToolbar.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit


protocol CompanyToolbarDelegate : class {
    func companyToolbar(_ : CompanyToolbar, requestedAction: CompanyToolbar.ActionType)
}

class CompanyToolbar: UIToolbar {
    
    enum ActionType : Int {
//        case showShare
//        case toggleHeart
        case showMap
    }
    
    weak var toolbarDelegate: CompanyToolbarDelegate?
    
    func mapAppearance(shown: Bool) {
        mapButton.tintColor = shown ? UIColor.blue :UIColor.black
    }
    
    var mapButton: UIBarButtonItem = {
        let image = UIImage(named: "pin_on_map")
        let button = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleButtonTapped))
        button.tag = ActionType.showMap.rawValue
        return button
    }()
    
    required init(toolbarDelegate: CompanyToolbarDelegate, alpha: CGFloat) {
        self.toolbarDelegate = toolbarDelegate
        super.init(frame: CGRect.zero)
        items = [
            makeFlexibleSpace(),
            mapButton,
            makeFlexibleSpace()
        ]
        let bgImageColor = UIColor.white.withAlphaComponent(alpha)
        let image = UIImage.onePixelImageWithColor(color: bgImageColor)
        setBackgroundImage(image, forToolbarPosition: .any, barMetrics: .default)
        setShadowImage(UIImage(), forToolbarPosition: .any)
        tintColor = UIColor.black
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        items = [mapButton]
    }
    
    @objc private func handleButtonTapped(sender: UIBarButtonItem) {
        let action = ActionType(rawValue: sender.tag)!
        toolbarDelegate?.companyToolbar(self, requestedAction: action)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeFlexibleSpace() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
}

fileprivate extension UIImage {
    static func onePixelImageWithColor(color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.setFillColor(color.cgColor)
        context!.fill(CGRect(x:0,y: 0, width: 1, height:1))
        return UIImage(cgImage: context!.makeImage()!)
    }
}
