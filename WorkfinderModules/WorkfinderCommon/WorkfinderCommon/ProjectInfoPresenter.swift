//
//  ProjectInfoPresenter.swift
//  WorkfinderCommon
//
//  Created by Keith on 20/08/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

public struct ProjectInfoPresenter {
    public var projectUuid: F4SUUID
    public var associationUuid: F4SUUID
    public var companyName: String
    public var hostName: String
    public var projectName: String
    public var requiresCandidateLocation: Bool
    
    public init(
        projectUuid: F4SUUID,
        associationUuid: F4SUUID,
        companyName: String,
        hostName: String,
        projectName: String,
        requiresCandidateLocation: Bool
    ) {
        self.projectUuid = projectUuid
        self.associationUuid = associationUuid
        self.companyName = companyName
        self.hostName = hostName
        self.projectName = projectName
        self.requiresCandidateLocation = requiresCandidateLocation
    }
    
    public init(json: ProjectJson) {
        let missing = "missing information"
        self.projectUuid = json.uuid ?? ""
        self.associationUuid = json.association?.uuid ?? missing
        self.companyName = json.association?.location?.company?.name ?? missing
        self.hostName = json.association?.host?.fullName ?? missing
        self.projectName = json.name ?? missing
        self.requiresCandidateLocation = json.isCandidateLocationRequired ?? true
    }
    
    public init(item: RecommendationsListItem) {
        let missing = "missing information"
        let project = item.project
        let association = item.association
        self.projectUuid = project?.uuid ?? missing
        self.associationUuid = association?.uuid ?? missing
        self.companyName = association?.location?.company?.name ?? missing
        self.hostName = association?.host?.fullName ?? missing
        self.projectName = project?.name ?? missing
        self.requiresCandidateLocation = true
    }
}
