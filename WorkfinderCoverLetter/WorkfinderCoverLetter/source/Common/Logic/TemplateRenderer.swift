import Foundation
import UIKit

public protocol TemplateRendererProtocol: class {
    var isComplete: Bool { get }
    func renderToPlainString(with keyValues: [String: String?]) -> String
    func renderToAttributedString(with keyValues: [String: String?]) -> NSAttributedString
}

public class TemplateRenderer: TemplateRendererProtocol {
    let fontSize: CGFloat = 20
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
    
    public func renderToAttributedString(with keyValues: [String : String?]) -> NSAttributedString {
        var fieldRanges = parser.allFieldRanges()
        var fieldNames = parser.allFieldNames()
        fieldRanges.reverse()
        fieldNames.reverse()
        let renderedString = NSMutableAttributedString(string: parser.templateString, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
        for index in 0..<fieldRanges.count {
            let name = fieldNames[index]
            let range = fieldRanges[index]
            let nsRange = NSRange(range, in: parser.templateString)
            guard let value = keyValues[name] else {
                let color = UIColor.systemOrange
                let attributes = [
                    NSAttributedString.Key.foregroundColor : color,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                    NSAttributedString.Key.coverLetterField: name
                ] as [NSAttributedString.Key : Any]
                renderedString.setAttributes(attributes, range: nsRange)
                let suffixRange = NSRange(location: nsRange.location + nsRange.length-2, length: 2)
                let prefixRange = NSRange(location: nsRange.location, length: 2)
                let suffix = NSAttributedString(string: "]", attributes: attributes)
                let prefix = NSAttributedString(string: "[", attributes: attributes)
                renderedString.replaceCharacters(in: suffixRange, with: suffix)
                renderedString.replaceCharacters(in: prefixRange, with: prefix)
                continue
            }
            guard let replacementText = value else { continue }
            let replacementAttributedText = replacementText
            let color = UIColor.systemGreen
            let attributes = [
                NSAttributedString.Key.foregroundColor : color,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedString.Key.coverLetterField: name
            ] as [NSAttributedString.Key : Any]
            renderedString.setAttributes(attributes, range: nsRange)
            renderedString.replaceCharacters(in: nsRange, with: replacementAttributedText)

        }
        return renderedString
    }
}

extension NSAttributedString.Key {
    static let coverLetterField = NSAttributedString.Key(rawValue: "coverLetterField")
}
