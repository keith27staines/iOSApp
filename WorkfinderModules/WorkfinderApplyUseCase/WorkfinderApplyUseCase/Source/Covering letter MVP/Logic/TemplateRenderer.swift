import Foundation
import UIKit

public protocol TemplateRendererProtocol: class {
    func renderToPlainString(with keyValues: [String: String?]) -> String
    func renderToAttributedString(with keyValues: [String: String?]) -> NSAttributedString
}

public class TemplateRenderer: TemplateRendererProtocol {
    
    let parser: TemplateParserProtocol
    
    public init(parser: TemplateParserProtocol) {
        self.parser = parser
    }
    
    public func renderToPlainString(with keyValues: [String: String?]) -> String {
        var fieldRanges = parser.allFieldRanges()
        var fieldNames = parser.allFieldNames()
        fieldRanges.reverse()
        fieldNames.reverse()
        var renderedString = parser.templateString
        for index in 0..<fieldRanges.count {
            let name = fieldNames[index]
            let range = fieldRanges[index]
            guard let value = keyValues[name] else { continue }
            guard let replacementText = value else { continue }
            renderedString = renderedString.replacingCharacters(in: range, with: replacementText)
        }
        return renderedString
    }
    
    public func renderToAttributedString(with keyValues: [String : String?]) -> NSAttributedString {
        var fieldRanges = parser.allFieldRanges()
        var fieldNames = parser.allFieldNames()
        fieldRanges.reverse()
        fieldNames.reverse()
        let renderedString = NSMutableAttributedString(string: parser.templateString, attributes: [:])
        for index in 0..<fieldRanges.count {
            let name = fieldNames[index]
            let range = fieldRanges[index]
            let nsRange = NSRange(range, in: parser.templateString)
            guard let value = keyValues[name] else {
                let color = UIColor.systemOrange
                renderedString.setAttributes([NSAttributedString.Key.foregroundColor : color], range: nsRange)
                continue
            }
            guard let replacementText = value else { continue }
            let replacementAttributedText = replacementText
            let color = UIColor.systemGreen
            renderedString.setAttributes([NSAttributedString.Key.foregroundColor : color], range: nsRange)
            renderedString.replaceCharacters(in: nsRange, with: replacementAttributedText)
        }
        return renderedString
    }
}
