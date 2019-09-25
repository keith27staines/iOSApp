//
//  F4SMessageModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

// MARK:- F4SMessageList
public struct F4SMessagesList : Codable {
    public var count: Int
    public var messages: [F4SMessage]
    
    public init() {
        count = 0
        messages = [F4SMessage]()
    }
}

// MARK:- F4SCannedResponse
public struct F4SCannedResponses : Codable {
    public var uuid: String
    public var options: [F4SCannedResponse]
    public init(uuid: String, responses: [F4SCannedResponse]) {
        self.uuid = uuid
        self.options = responses
    }
}

public struct F4SCannedResponse : Codable {
    public var uuid: F4SUUID
    public var value: String
    public init(uuid: F4SUUID, value: String) {
        self.uuid = uuid
        self.value = value
    }
}

// MARK:- F4SAction
public struct F4SAction : Codable {
    public var originatingMessageUuid: F4SUUID?
    public var actionType: F4SActionType?
    public var arguments: [F4SActionArgument]?
    
    public func argument(name: F4SActionArgumentName) -> F4SActionArgument? {
        guard let arguments = arguments else { return nil }
        return arguments.filter({ (arg) -> Bool in
            return arg.argumentName == name
        }).first
    }
    
    public init(originatingMessageUuid: F4SUUID?, actionType: F4SActionType?, arguments: [F4SActionArgument]?) {
        self.originatingMessageUuid = originatingMessageUuid
        self.actionType = actionType
        self.arguments = arguments
    }
}

extension F4SAction {
    private enum CodingKeys : String, CodingKey {
        case originatingMessageUuid = "originating_message_uuid"
        case actionType = "action_type"
        case arguments = "arguments"
    }
}

public enum F4SActionType : String, Codable {
    
    case uploadDocuments = "upload_documents"
    case viewOffer = "view_offer"
    case viewCompanyExternalApplication = "view_company_ext_application"
    
    public var actionTitle: String {
        switch self {
        case .uploadDocuments:
            return NSLocalizedString("Add documents", comment: "Action request from business leader asking young person to upload certain documents (which are specified elsewhere)")
        case .viewOffer:
            return NSLocalizedString("View offer", comment: "Action request directing young person to view their offer")
        case .viewCompanyExternalApplication:
            return NSLocalizedString("Apply externally", comment: "Takes the user to a 3rd party website to apply there")
        }
    }
}

// MARK:- F4SActionArgument
public struct F4SActionArgument : Codable {
    public var argumentName: F4SActionArgumentName
    public var value: [String]
    public init(name: F4SActionArgumentName, value: [String]) {
        self.argumentName = name
        self.value = value
    }
}

extension F4SActionArgument {
    
    private enum CodingKeys: String, CodingKey {
        case argumentName = "arg_name"
        case value = "value"
    }
}

public enum F4SActionArgumentName: String, Codable {
    case placementUuid = "placement_uuid"
    case documentType = "doc_type"
    case externalWebsite = "external_website"
}


