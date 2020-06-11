//
//  UniversalLinkParser.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 22/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public class DeepLink  {
    
    enum DeepLinkType {
    case recommendAssociation
    }
    
    public init() {
    }
    
    public func handleUrl(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
        
        return false
    }
    
    public static func isRecommendation(url: URL) -> Bool {
        return extractRecommendedCompanyUuid(from: url) == nil ? false : true
    }
    
    public static func extractRecommendedCompanyUuid(from url: URL) -> String? {
        var shortUrl = url
        let overviewComponent = shortUrl.lastPathComponent
        guard overviewComponent == "overview" else {
            return nil
        }
        shortUrl = shortUrl.deletingLastPathComponent()
        let companyUuidComponent = shortUrl.lastPathComponent
        shortUrl = shortUrl.deletingLastPathComponent()
        let companyComponent = shortUrl.lastPathComponent
        guard companyComponent == "company" else {
            return nil
        }
        
        guard companyUuidComponent.count == "dc389f17-abf6-4c01-adb8-065deaefa821".count else {
            return nil
        }
        return companyUuidComponent
    }
}

