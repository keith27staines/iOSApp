//
//  NPS.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation

public class NPSModel {
    public var accessToken: String?
    public var reviewUuid: String?
    public var score: Int?
    public var category: QuestionCategory?
    public var hostName: String?
    public var projectName: String?
    public var companyName: String?
    
    public init(
        accessToken: String?,
        uuid: String?,
        score: Int?,
        category: QuestionCategory?,
        hostName: String?,
        projectName: String?,
        companyName: String?
    ) {
        self.accessToken = accessToken
        self.reviewUuid = uuid
        self.score = score
        self.category = category
        self.hostName = hostName
        self.projectName = projectName
        self.companyName = companyName
    }
}
