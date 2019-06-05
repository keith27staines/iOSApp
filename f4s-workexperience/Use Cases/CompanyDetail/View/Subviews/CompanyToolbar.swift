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
        case showShare
        case toggleHeart
        case showMap
    }
    
    weak var toolbarDelegate: CompanyToolbarDelegate?
    
    var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(handleButtonTapped))
        button.tag = ActionType.showShare.rawValue
        button.tintColor = UIColor.gray
        return button
    }()
    
    func heartAppearance(hearted: Bool) {
        let on = #imageLiteral(resourceName: "heartFilled")
        let off = UIImage(named: "heartOutline")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        heartButton.image = hearted ? on : off
        heartButton.tintColor = hearted ? UIColor.blue : UIColor.gray
    }
    
    func mapAppearance(shown: Bool) {
        mapButton.tintColor = shown ? UIColor.blue : UIColor.gray
    }
    
    var heartButton: UIBarButtonItem = {
        let heartImage = UIImage(named: "heartOutline")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        let button = UIBarButtonItem(image: heartImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleButtonTapped))
        button.tag = ActionType.toggleHeart.rawValue
        return button
    }()
    
    var mapButton: UIBarButtonItem = {
        let image = UIImage(named: "pin_on_map")
        let button = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleButtonTapped))
        button.tag = ActionType.showMap.rawValue
        return button
    }()
    
    required init(toolbarDelegate: CompanyToolbarDelegate) {
        self.toolbarDelegate = toolbarDelegate
        super.init(frame: CGRect.zero)
        items = [
            makeFlexibleSpace(),
            shareButton,
            makeFlexibleSpace(),
            heartButton,
            makeFlexibleSpace(),
            mapButton,
            makeFlexibleSpace()
        ]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        items = [shareButton,heartButton, mapButton]
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
