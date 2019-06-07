//
//  String+Extensions.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

extension String {
    public func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    public func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    public func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

//MARK:- Stripping LTD etc postfixes
extension String {
    public func stripCompanySuffix() -> String {
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
public extension String {
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
    
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func index(of string: String, options: String.CompareOptions = .literal) -> String.Index? {
        return range(of: string, options: options, range: nil, locale: nil)?.lowerBound
    }
    
    func index(of string: String, options: String.CompareOptions = .literal) -> Int? {
        if let indexOf = range(of: string, options: options, range: nil, locale: nil)?.lowerBound {
            return self.distance(from: self.startIndex, to: indexOf)
        }
        return nil
    }
    
    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}


