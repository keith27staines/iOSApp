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
                renderedString.setAttributes([NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], range: nsRange)
                continue
            }
            guard let replacementText = value else { continue }
            let replacementAttributedText = replacementText
            let color = UIColor.systemGreen
            renderedString.setAttributes([NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], range: nsRange)
            renderedString.replaceCharacters(in: nsRange, with: replacementAttributedText)
        }
        return renderedString
    }
}
