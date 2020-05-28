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

// MARK:- Dehyphenating
public extension String {
    /// Returns the string with hyphens removed (thus "ABC-DEF" -> "ABCDEF"
    var dehyphenated: String {
        return self.replacingOccurrences(of: "-", with: "")
    }
    /// Returns the string with html encodings removed
    func htmlDecode() -> String {
        return self
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
    /// returns the string with the very first letter capitalized
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
    
    /// mutates the current instance by capitalizing the first letter (if is is not already)
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
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


