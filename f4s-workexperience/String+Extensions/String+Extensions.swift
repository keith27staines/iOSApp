//
//  String+Extensions.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 16/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//
import UIKit

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

//MARK:- Stripping LTD etc postfixes
extension String {
    func stripCompanySuffix() -> String {
        let companyEndings = [" limited", " ltd", "ltd.", " plc"]
        var stripped = self
        companyEndings.forEach { (ending) in
            if hasSuffix(ending) || hasSuffix(ending.uppercased()){
                stripped = String(dropLast(ending.count))
            }
        }
        return stripped
    }
}

// MARK:- Dehyphenating
extension String {
    var dehyphenated: String {
        return self.replacingOccurrences(of: "-", with: "")
    }
    
    func htmlDecode() -> String {
        return self
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}
