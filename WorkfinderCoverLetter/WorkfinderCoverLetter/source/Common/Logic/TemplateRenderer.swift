import Foundation
import UIKit
import WorkfinderUI

public protocol TemplateRendererProtocol: AnyObject {
    var isComplete: Bool { get }
    func renderToPlainString(with keyValues: [String: String?]) -> String
    func renderToAttributedString(with keyValues: [String: String?]) -> NSAttributedString
}

public class TemplateRenderer: TemplateRendererProtocol {
    let fontSize: CGFloat = 19
    let parser: TemplateParserProtocol
    
    public init(parser: TemplateParserProtocol) {
        self.parser = parser
    }
    
    public var isComplete: Bool = false
    
    public func renderToPlainString(with keyValues: [String: String?]) -> String {
        isComplete = true
        var fieldRanges = parser.allFieldRanges()
        var fieldNames = parser.allFieldNames()
        fieldRanges.reverse()
        fieldNames.reverse()
        var renderedString = parser.templateString
        for index in 0..<fieldRanges.count {
            let name = fieldNames[index]
            let range = fieldRanges[index]
            guard let value = keyValues[name] else {
                isComplete = false
                continue
            }
            guard let replacementText = value else {
                isComplete = false
                continue
            }
            renderedString = renderedString.replacingCharacters(in: range, with: replacementText)
        }
        return renderedString
    }
    
    let fieldForegroundColor = UIColor.black
    let fieldBackgroundColor = UIColor(red:1, green:0.96, blue:0.82, alpha:1)
    
    public func renderToAttributedString(with keyValues: [String : String?]) -> NSAttributedString {

        var fieldRanges = parser.allFieldRanges()
        var fieldNames = parser.allFieldNames()
        fieldRanges.reverse()
        fieldNames.reverse()
        
        let renderedString = NSMutableAttributedString(string: parser.templateString)
    
        for index in 0..<fieldRanges.count {
            let fieldName = fieldNames[index]
            let fieldValue = keyValues[fieldName]
            let range = fieldRanges[index]
            let nsRange = NSRange(range, in: parser.templateString)
            guard let value = fieldValue else {
                let attributes = attributesForField(fieldName: fieldName, hasValue: false)
                renderedString.setAttributes(attributes, range: nsRange)
                let suffixRange = NSRange(location: nsRange.location + nsRange.length-2, length: 2)
                let prefixRange = NSRange(location: nsRange.location, length: 2)
                if isFieldFixed(name: fieldName) {
                    let prefix = NSAttributedString(string: " ", attributes: attributes)
                    let suffix = NSAttributedString(string: " ", attributes: attributes)
                    renderedString.replaceCharacters(in: suffixRange, with: suffix)
                    renderedString.replaceCharacters(in: prefixRange, with: prefix)
                } else {
                    let prefix = NSAttributedString(string: "[", attributes: attributes)
                    let suffix = NSAttributedString(string: "]", attributes: attributes)
                    renderedString.replaceCharacters(in: suffixRange, with: suffix)
                    renderedString.replaceCharacters(in: prefixRange, with: prefix)
                }
                continue
            }
            guard let replacementText = value else { continue }
            let replacementAttributedText = replacementText
            let attributes = attributesForField(fieldName: fieldName, hasValue: true)
            renderedString.setAttributes(attributes, range: nsRange)
            renderedString.replaceCharacters(in: nsRange, with: replacementAttributedText)

        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0.5 * fontSize
        renderedString.addAttributes(
            [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ],
            range:NSMakeRange(0, renderedString.length)
        )
        return renderedString
    }
    
    func attributesForField(fieldName: String, hasValue: Bool) -> [NSAttributedString.Key: Any] {
        let isFixed = self.isFieldFixed(name: fieldName)
        switch isFixed {
        case true:
            return [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)
            ] as [NSAttributedString.Key : Any]
        case false:
            switch hasValue {
            case true:
                return [
                    NSAttributedString.Key.foregroundColor : WorkfinderColors.primaryColor,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                    NSAttributedString.Key.coverLetterField: fieldName
                ] as [NSAttributedString.Key : Any]
            case false:
                return [
                    NSAttributedString.Key.foregroundColor : UIColor.orange,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                    NSAttributedString.Key.coverLetterField: fieldName
                ] as [NSAttributedString.Key : Any]
            }

        }
    }
    
    func isFieldFixed(name: String) -> Bool {
        ["host", "project title", "company"].contains(name)
    }
    
    
}

extension NSAttributedString.Key {
    static let coverLetterField = NSAttributedString.Key(rawValue: "coverLetterField")
}

