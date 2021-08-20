//
//  ProjectInfoPresenter.swift
//  WorkfinderCommon
//
//  Created by Keith on 20/08/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

public struct ProjectInfoPresenter {
    private static let missing = "-"
    public var hostUuid: F4SUUID
    public var projectUuid: F4SUUID
    public var associationUuid: F4SUUID
    public var companyName: String
    public var hostName: String
    public var projectName: String
    public var requiresCandidateLocation: Bool
    
    public init(
        hostUuid: F4SUUID,
        projectUuid: F4SUUID,
        associationUuid: F4SUUID,
        companyName: String,
        hostName: String,
        projectName: String,
        requiresCandidateLocation: Bool
    ) {
        self.hostUuid = hostUuid
        self.projectUuid = projectUuid
        self.associationUuid = associationUuid
        self.companyName = companyName
        self.hostName = hostName
        self.projectName = projectName
        self.requiresCandidateLocation = requiresCandidateLocation
    }
    
    public init(json: ProjectJson) {
        self.hostUuid = json.association?.host?.uuid ?? Self.missing
        self.projectUuid = json.uuid ?? Self.missing
        self.associationUuid = json.association?.uuid ?? Self.missing
        self.companyName = json.association?.location?.company?.name ?? Self.missing
        self.hostName = json.association?.host?.fullName ?? Self.missing
        self.projectName = json.name ?? Self.missing
        self.requiresCandidateLocation = json.isCandidateLocationRequired ?? true
    }

    public init(item: RecommendationsListItem) {
        let project = item.project
        let association = item.association
        self.hostUuid = item.association?.host?.uuid ?? Self.missing
        self.projectUuid = project?.uuid ?? Self.missing
        self.associationUuid = association?.uuid ?? Self.missing
        self.companyName = association?.location?.company?.name ?? Self.missing
        self.hostName = association?.host?.fullName ?? Self.missing
        self.projectName = project?.name ?? Self.missing
        self.requiresCandidateLocation = true
    }
}
