//
//  F4SAnalyticsEvents.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 14/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public enum F4SAnalyticsEventName: String {
    case viewCompanyExternalApplication = "yp_viewed_company_external_application_page"
}

public struct F4SAnalyticsEvent {
    
    public init(name: F4SAnalyticsEventName, properties: [String: String]? = nil) {
        self.name = name
        self.properties = properties ?? [String:String]()
    }
    
    public let name: F4SAnalyticsEventName
    public private (set) var properties: [String: String]
    
    public mutating func addProperty(name: String, value: String) {
        properties[name] = value
    }
    public func track() {
        //SEGAnalytics.shared()?.track(name.rawValue, properties: properties)
    }
}


