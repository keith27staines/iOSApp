
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
    
    var fieldNameMapping: [String: String]?
    
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

class TemplateModelPreprocessor {
    
    static let replacementMap: [String:String] = [
        "host"                  : "host",               // fixedField value
        "company"               : "company",            // fixedField value
        "candidate"             : "candidate",          // fixedField value
        "projectTitle"          : "project title",      // fixedField value
        "skills"                : "skills I want",      // picklist type
        "attributes"            : "attributes",         // picklist type
        "university"            : "university",         // picklist type
        "yearOfStudy"           : "year of study",      // picklist type
        "motivation"            : "Motivation",         // picklist type
        "experience"            : "Experience",         // picklist type
        "availabilityPeriod"    : "availability period",// picklist type
        "subject"               : "subject",            // picklist type
        "placementType"         : "placement type",     // picklist type
        "project"               : "project",            // picklist type
        "duration"              : "duration",           // picklist type
        "strongestSkills"       : "skills"
    ]
    
    func preprocess(templateModel: TemplateModel, fieldNameMapping: [String: String]? = TemplateModelPreprocessor.replacementMap) -> TemplateModel {
        guard let fieldNameMapping = fieldNameMapping else {
            return templateModel
        }
        var processedModel = templateModel
        for (field,mappedField) in fieldNameMapping {
            let decoratedField = "{{\(field)}}"
            let decoratedMappedField = "{{\(mappedField)}}"
            processedModel.templateString = processedModel.templateString.replacingOccurrences(of: decoratedField, with: decoratedMappedField)
        }
        return processedModel
    }
}
