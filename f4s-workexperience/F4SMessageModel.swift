//
//  F4SMessageModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SMessage : Codable {
    
}

public struct F4SCannedResponses : Codable {
    public var uuid: String
    public var options: [F4SCannedResponse]
}

public struct F4SCannedResponse : Codable {
    public var uuid: F4SUUID
    public var value: String
}

public struct F4SAction : Codable {
    public var originatingMessageUuid: F4SUUID
    public var actionType: F4SActionType
    public var arguments: [F4SActionArgument]
    
    public func argument(name: F4SActionArgumentName) -> F4SActionArgument? {
        return arguments.filter({ (arg) -> Bool in
            return arg.argumentName == name
        }).first
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
    
    var actionTitle: String {
        switch self {
        case .uploadDocuments:
            return NSLocalizedString("Add documents", comment: "Action request from business leader asking young person to upload certain documents (which are specified elsewhere)")
        }
    }
}


public enum F4SActionArgumentName: String, Codable {
    case placementUuid = "placement_uuid"
    case documentType = "doc_type"
}

public struct F4SActionArgument : Codable {
    public var argumentName: F4SActionArgumentName
    public var value: [String]
}

extension F4SActionArgument {
    
    private enum CodingKeys: String, CodingKey {
        case argumentName = "arg_name"
        case value = "value"
    }
}


