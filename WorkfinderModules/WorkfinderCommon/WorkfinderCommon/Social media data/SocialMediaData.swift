//
//  SocialMediaData.swift
//  WorkfinderCommon
//
//  Created by Keith on 30/06/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

public struct LinkedinConnectionData: Codable {
    
    public var id: Int?
    public var provider: String?
    public var extra_data: LinkedinData?
}

public struct LinkedinData: Codable {
    public var id: String?
    public var educations: [String:LIEducation]?
    public var skills: [String: LISkill]?
    public var positions: [String: LIPosition]?
}

public struct LIEducation: Codable {
    public var startMonthYear: LIMonthYear?
    public var endMonthYear: LIMonthYear?
    public var degreeName: LILocalizedString?
    public var fieldsOfStudy: [LIFieldOfStudy]?
    public var schoolName: LILocalizedString?
}

public struct LIMonthYear: Codable {
    public var year: Int?
    public var month: Int?
}

public struct LIFieldOfStudy: Codable {
    public var fieldOfStudyName: LILocalizedString?
}

public struct LIPosition: Codable {
    public var locationName: LILocalizedString?
    public var title: LILocalizedString?
    public var companyName: LILocalizedString?
    public var startMonthYear: LIMonthYear?
    public var endMonthYear: LIMonthYear?
}

public struct LISkill: Codable {
    public var name: LILocalizedString?
}

public struct LILocalizedString: Codable {
    public struct LILocalized: Codable {
        public var en_US: String?
    }
    public var localized: LILocalized?
    public var string: String? { localized?.en_US }
}


