//
//  ApplicationLetterTextFormatter.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

class ApplicationLetterTextDecorator {
    
    init() {}
    
    func decorateLetterText(_ letterText: String) -> NSAttributedString {
        
        // normal font to begin
        var customMutableAttributedString: [([NSAttributedString.Key: Any], NSRange)] = []
        var intermediateTemplateString: String = letterText.replacingOccurrences(of: "\r", with: "")
        
        // find first selection
        while true {
            var smalestIndex: Int = intermediateTemplateString.count
            var customParse: TemplateCustomParse?
            if let placeholder = intermediateTemplateString.index(of: TemplateCustomParse.startPlaceholder.rawValue) as Int? {
                if placeholder < smalestIndex {
                    // first attribute is one with placeholder
                    smalestIndex = placeholder
                    customParse = TemplateCustomParse.startPlaceholder
                }
            }
            if let selected = intermediateTemplateString.index(of: TemplateCustomParse.startSelected.rawValue) as Int? {
                if selected < smalestIndex {
                    // first attribute is one with one already selected
                    smalestIndex = selected
                    customParse = TemplateCustomParse.startSelected
                }
            }
            if let bold = intermediateTemplateString.index(of: TemplateCustomParse.startBold.rawValue) as Int? {
                if bold < smalestIndex {
                    // first attribute is one with one already selected
                    smalestIndex = bold
                    customParse = TemplateCustomParse.startBold
                }
            }
            
            if smalestIndex == intermediateTemplateString.count {
                // no more data to set
                break
            }
            
            // remove start string
            guard let customParseEnum = customParse,
                let customParseValue = customParse?.rawValue else {
                    continue
            }
            
            var temp = intermediateTemplateString.stringByReplacingFirstOccurrenceOfString(target: customParseValue, withString: "")
            intermediateTemplateString = temp
            switch customParseEnum
            {
            case .startSelected:
                // should be colored with green
                
                // find the end selected string
                if let endSelected = intermediateTemplateString.index(of: TemplateCustomParse.endSelected.rawValue) as Int? {
                    // remove endSelectedString
                    temp = intermediateTemplateString.stringByReplacingFirstOccurrenceOfString(target: TemplateCustomParse.endSelected.rawValue, withString: "")
                    intermediateTemplateString = temp
                    
                    // apply attributed text for that range
                    customMutableAttributedString.append(([NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.mediumGreen)], range: NSRange(location: smalestIndex, length: endSelected - smalestIndex)))
                }
                
            case .startPlaceholder:
                // should be colored with orange
                
                // find the end placeholder string
                if let endPlaceholder = intermediateTemplateString.index(of: TemplateCustomParse.endPlaceholder.rawValue) as Int? {
                    // remove endSelectedString
                    temp = intermediateTemplateString.stringByReplacingFirstOccurrenceOfString(target: TemplateCustomParse.endPlaceholder.rawValue, withString: "")
                    intermediateTemplateString = temp
                    
                    // apply attributed text for that range
                    customMutableAttributedString.append(([NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.orangeNormal)], range: NSRange(location: smalestIndex, length: endPlaceholder - smalestIndex)))
                }
                
            case .startBold:
                // should be bold
                
                // find the end bold string
                if let endBold = intermediateTemplateString.index(of: TemplateCustomParse.endBold.rawValue) as Int? {
                    // remove endSelectedString
                    temp = intermediateTemplateString.stringByReplacingFirstOccurrenceOfString(target: TemplateCustomParse.endBold.rawValue, withString: "")
                    intermediateTemplateString = temp
                    
                    // apply attributed text for that range
                    customMutableAttributedString.append(([NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedString.Key.foregroundColor: UIColor.black], range: NSRange(location: smalestIndex, length: endBold - smalestIndex)))
                }
            
            default:
                break
            }
        }
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 34 - UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular).lineHeight
        let mutableAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: intermediateTemplateString, attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor.black])
        for attrString in customMutableAttributedString {
            mutableAttributedString.addAttributes(attrString.0, range: attrString.1)
        }
        
        return mutableAttributedString
    }
}
