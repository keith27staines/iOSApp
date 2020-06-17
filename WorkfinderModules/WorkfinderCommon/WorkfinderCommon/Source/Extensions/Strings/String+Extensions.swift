//
//  String+Extensions.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

extension String {
    /// Returns the width of string if rendered using the specified font
    public func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    /// Returns the height of string if rendered using the specified font
    public func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    /// Returns the size of box containing the string if rendered using the specified font
    public func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}



//MARK:- Stripping LTD etc postfixes
extension String {
    /// Removes common company suffixes including ltd, plc etc, whether
    /// capitalized or not
    public func stripCompanySuffix() -> String {
        let companyEndings = [" limited", " ltd", " ltd.", " plc"]
        var stripped = self
        companyEndings.forEach { (ending) in
            if hasSuffix(ending) || hasSuffix(ending.uppercased()){
                stripped = String(dropLast(ending.count))
            }
        }
        return stripped
    }
}

public extension String {
    /// returns the String.Index of the first letter of the first occurrence of the specified string
    func index(of string: String, options: String.CompareOptions = .literal) -> String.Index? {
        return range(of: string, options: options, range: nil, locale: nil)?.lowerBound
    }
    
    /// returns the ascii character index of the first letter of the first occurrence of the specified string
    func index(of string: String, options: String.CompareOptions = .literal) -> Int? {
        if let indexOf = range(of: string, options: options, range: nil, locale: nil)?.lowerBound {
            return self.distance(from: self.startIndex, to: indexOf)
        }
        return nil
    }
    
    /// Returns a string in which the first occurrence of the specified substring in the current instance is replaced by the specified replacement
    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}


