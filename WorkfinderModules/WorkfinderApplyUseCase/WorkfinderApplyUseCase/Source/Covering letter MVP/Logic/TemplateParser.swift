
import Foundation
import WorkfinderCommon

public protocol TemplateParserProtocol {
    var templateString: String { get }
    func allFieldRanges() -> [Range<String.Index>]
    func allFieldStrings() -> [String]
    func allFieldNames() -> [String]
}

public class TemplateParser: TemplateParserProtocol {
    let templateModel: TemplateModel
    var searchStart: String.Index?
    var searchEnd: String.Index?
    
    var searchRange: Range<String.Index>? {
        guard let start = searchStart, let end = searchEnd else { return nil }
        return start..<end
    }
    
    public var templateString: String { return templateModel.templateString }
    
    public init(templateModel: TemplateModel) {
        self.templateModel = templateModel
        searchStart = templateString.startIndex
        searchEnd = templateString.endIndex
    }
    
    public func allFieldNames() -> [String] {
        return allFieldStrings().map { (fieldString) -> String in
            return fieldNameFromFieldString(fieldString)
        }
    }
    
    public func allFieldStrings() -> [String] {
        return allFieldRanges().map { (range) -> String in
            return stringForRange(range)
        }
    }
    
    public func allFieldRanges() -> [Range<String.Index>] {
        searchStart = templateString.startIndex
        var fields = [Range<String.Index>]()
        var range: Range<String.Index>? = nextFieldRange()
        while range != nil {
            fields.append(range!)
            searchStart = range?.upperBound
            range = nextFieldRange()
        }
        return fields
    }
    
    func findRangeOfNextDelimiterOfType(_ type: TemplateField.DelimiterType) -> Range<String.Index>? {
        let delimterString = type.rawValue
        let nextStart = templateString.range(of: delimterString, range: searchRange)
        return nextStart
    }
    
    func fieldNameFromFieldString(_ fieldString: String) -> String {
        return String(fieldString
        .dropFirst(TemplateField.DelimiterType.start.rawValue.count)
        .dropLast(TemplateField.DelimiterType.end.rawValue.count))
    }
    
    func stringForRange(_ range: Range<String.Index>) -> String {
        return String(templateString[range])
    }
    
    func nextFieldString() -> String? {
        guard let fieldRange = nextFieldRange() else { return nil }
        let fieldString = templateString[fieldRange]
        return String(fieldString)
    }
    
    func nextFieldRange() -> Range<String.Index>? {
        guard
            let fieldStartDelimiterRange = findRangeOfNextDelimiterOfType(.start),
            let fieldEndDelimiterRange = findRangeOfNextDelimiterOfType(.end)
            else {
                return nil
            }
        return fieldStartDelimiterRange.lowerBound..<fieldEndDelimiterRange.upperBound
    }
}
