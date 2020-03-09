//
//  ComanyFileParser.swift
//  FileParser
//
//  Created by Keith Dev on 06/03/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import Foundation


// PinDownloadFile is company-locations-and-tags.jsonl

public class PinDownloadFileParser {
    
    public enum CompanyFileParserError: Error, Equatable {
        case emptyFile
        case unknownVersion(String)
    }

    public let lineCount: Int
    
    let fileString: String
    let lines: [Substring]
    let versionString: String
    
    public init(fileString: String) throws {
        self.fileString = fileString
        let lines = fileString.split(separator: "\n")
        self.versionString = String(lines[0])
        self.lineCount = lines.count
        self.lines = [Substring](lines.dropFirst())
        switch versionString {
        case "version 1.0":
            // we have a parser for this version
            break
        default:
            // no parser
            throw CompanyFileParserError.unknownVersion(versionString)
        }
    }
    
    public func extractPins() -> [PinJson] {
        return lines.map { (line) -> PinJson in
            pinJsonFromLineString(lineString: String(line))
        }
    }
    
    func pinJsonFromLineString(lineString: String) -> PinJson {
        let jsonifiedString = self.jsonifiedString(from: lineString)
        return try! JSONDecoder().decode(PinJson.self, from: jsonifiedString.data(using: .utf8)!)
    }
    
    func jsonifiedString(from lineString: String) -> String {
        var jsonified: String = lineString
        jsonified = replaceTerminatingSquareBrackets(lineString: jsonified)
        jsonified = insertCompanyUuidKey(lineString: jsonified)
        jsonified = insertLatitudeLongitudeKeys(lineString: jsonified)
        return jsonified
    }
    
    func replaceTerminatingSquareBrackets(lineString: String) -> String {
        let start = lineString.startIndex
        let end = lineString.endIndex
        let firstCharacterRange = start..<lineString.index(start, offsetBy: 1)
        let lastCharacterRange = lineString.index(end, offsetBy: -1)..<end
        return lineString
            .replacingCharacters(in: firstCharacterRange, with: "{")
            .replacingCharacters(in: lastCharacterRange, with: "}")
    }
    
    func insertCompanyUuidKey(lineString: String) -> String {
        var modifiedString = lineString
        let start = modifiedString.startIndex
        modifiedString.insert(contentsOf: "\"companyUuid\":", at: modifiedString.index(start, offsetBy: 1))
        return modifiedString
    }
    
    func insertLatitudeLongitudeKeys(lineString: String) -> String {
        var modifiedString = lineString
        let firstCommaIndex = modifiedString.firstIndex(of: ",")!
        let secondCommaIndex = modifiedString[modifiedString.index(after: firstCommaIndex)...].firstIndex(of: ",")!
        let thirdCommaIndex = modifiedString[modifiedString.index(after: secondCommaIndex)...].firstIndex(of: ",")!
        modifiedString.insert(contentsOf: "\"tags\":", at: modifiedString.index(after: thirdCommaIndex))
        modifiedString.insert(contentsOf: "\"lon\":", at: modifiedString.index(after: secondCommaIndex))
        modifiedString.insert(contentsOf: "\"lat\":", at: modifiedString.index(after: firstCommaIndex))
        return modifiedString
    }
}
