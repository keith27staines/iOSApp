//
//  UniversalLinkParser.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 22/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public enum UniversalLink  {
    
    case recommendCompany(Company?)
    case passwordless(String?)
    
    public init?(url: URL) {
        if UniversalLink.isRecommendation(url: url) {
            guard let uuid = UniversalLink.extractRecommendedCompanyUuid(from: url) else {
                return nil
            }
            let company = DatabaseOperations.sharedInstance.companyWithUUID(uuid)
            self = .recommendCompany(company)
            return
        }
        if UniversalLink.isPasswordless(url: url) {
            guard let passcode = UniversalLink.extractPasscode(from: url) else {
                return nil
            }
            self = .passwordless(passcode)
            return
        }
        return nil
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
    
    public static func isPasswordless(url: URL) -> Bool {
        if let bundleId = bundleIdentifier() {
            if !doesPathOfURL(url, contain: bundleId) { return false }
        }
        guard let _ = extractPasscode(from: url) else { return false }
        return true
    }
    
    public static func extractPasscode(from url: URL) -> String? {
        guard let components = self.components(from: url) else { return nil }
        guard let items = components.queryItems else { return nil }
        guard let key = items.filter({ $0.name == "code" }).first, let passcode = key.value, Int(passcode) != nil else { return nil }
        return passcode
    }
}

// MARK:- helpers for passwordless
extension UniversalLink {
    
    static func doesPathOfURL(_ url: URL, contain string: String) -> Bool {
        guard let components = components(from: url) else { return false }
        let path = components.path.lowercased()
        return path.contains(string.lowercased())
    }
    
    static func components(from url: URL) -> URLComponents? {
        return URLComponents(url: url, resolvingAgainstBaseURL: true)
    }
    
    static func bundleIdentifier() -> String? {
        return Bundle.main.bundleIdentifier
    }
}
