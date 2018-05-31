//
//  F4SMessageServices.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 09/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SMessageService {
    var apiName: String { get }
    var threadUuid: String { get }
    
    func getMessages(completion: @escaping (F4SNetworkResult<[F4SMessage]>) -> ())
}

public protocol F4SMessageActionServiceProtocol {
    var apiName: String { get }
    var threadUuid: String { get }
    
    func getMessageAction(completion: @escaping (F4SNetworkResult<F4SAction?>) -> ())
}

public protocol F4SCannedMessageResponsesServiceProtocol {
    
    var apiName: String { get }
    var threadUuid: String { get }
    
    func getPermittedResponses(completion: @escaping (F4SNetworkResult<F4SCannedResponses>) -> ())
    
}

public class F4SCannedMessageResponsesService : F4SDataTaskService {
    public typealias SuccessType = F4SCannedResponses
    
    public let threadUuid: String
    
    public init(threadUuid: F4SUUID) {
        self.threadUuid = threadUuid
        let apiName = "messaging/\(threadUuid)/possible_responses"
        super.init(baseURLString: Config.BASE_URL2, apiName: apiName, objectType: SuccessType.self)
    }
}

// MARK:- F4SCannedMessageResponsesServiceProtocol conformance
extension F4SCannedMessageResponsesService : F4SCannedMessageResponsesServiceProtocol {
    
    public func getPermittedResponses(completion: @escaping (F4SNetworkResult<F4SCannedResponses>) -> ()) {
        super.get(attempting: "Get message options for thread", completion: completion)
    }
}

public class F4SMessageActionService : F4SDataTaskService {
    public typealias SuccessType = F4SAction
    
    public let threadUuid: String
    
    public init(threadUuid: F4SUUID) {
        self.threadUuid = threadUuid
        let apiName = "messaging/\(threadUuid)/user_action"
        super.init(baseURLString: Config.BASE_URL2, apiName: apiName, objectType: SuccessType.self)
    }
}

// MARK:- F4SMessageActionServiceProtocol conformance
extension F4SMessageActionService : F4SMessageActionServiceProtocol {
    
    public func getMessageAction(completion: @escaping (F4SNetworkResult<F4SAction?>) -> ()) {
        super.get(attempting: "Get action for thread", completion: completion)
    }
}





