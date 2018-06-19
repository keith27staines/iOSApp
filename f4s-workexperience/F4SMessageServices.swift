//
//  F4SMessageServices.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 09/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

// MARK:- F4SMessageService
public protocol F4SMessageServiceProtocol {
    var apiName: String { get }
    var threadUuid: String { get }
    func getMessages(completion: @escaping (F4SNetworkResult<F4SMessagesList>) -> ())
    func sendMessage(responseUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SMessagesList>) -> Void)
}

public class F4SMessageService : F4SDataTaskService {
    
    public let threadUuid: String
    
    public init(threadUuid: F4SUUID) {
        self.threadUuid = threadUuid
        let apiName = "messaging/\(threadUuid)"
        super.init(baseURLString: Config.BASE_URL2, apiName: apiName)
    }
}

extension F4SMessageService : F4SMessageServiceProtocol {
    
    public func getMessages(completion: @escaping (F4SNetworkResult<F4SMessagesList>) -> ()) {
        beginGetRequest(attempting: "Get messages for thread", completion: completion)
    }
    
    public func sendMessage(responseUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SMessagesList>) -> Void) {
        let attempting = "Send message to thread"
        let sendDictionary = ["response_uuid": responseUuid]
        super.beginSendRequest(verb: .put, objectToSend: sendDictionary, attempting: attempting, completion: {
            result in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let data):
                guard let data = data else {
                    completion(F4SNetworkResult.success(F4SMessagesList()))
                    return
                }
                let decoder = self.jsonDecoder
                do {
                    let messages = try decoder.decode(F4SMessagesList.self, from: data)
                    completion(F4SNetworkResult.success(messages))
                } catch {
                    let error = F4SNetworkDataErrorType.deserialization(data).error(attempting: attempting)
                    completion(F4SNetworkResult.error(error))
                }
            }
        })
    }
}

// MARK:- F4SMessageActionService
public protocol F4SMessageActionServiceProtocol {
    var apiName: String { get }
    var threadUuid: String { get }
    func getMessageAction(completion: @escaping (F4SNetworkResult<F4SAction?>) -> ())
}

public class F4SMessageActionService : F4SDataTaskService {
    
    public let threadUuid: String
    
    public init(threadUuid: F4SUUID) {
        self.threadUuid = threadUuid
        let apiName = "messaging/\(threadUuid)/user_action"
        super.init(baseURLString: Config.BASE_URL2, apiName: apiName)
    }
}

// MARK:- F4SMessageActionServiceProtocol conformance
extension F4SMessageActionService : F4SMessageActionServiceProtocol {
    
    public func getMessageAction(completion: @escaping (F4SNetworkResult<F4SAction?>) -> ()) {
        beginGetRequest(attempting: "Get action for thread", completion: completion)
    }
    
}

// MARK:- F4SCannedMessageResponsesService
public protocol F4SCannedMessageResponsesServiceProtocol {
    
    var apiName: String { get }
    var threadUuid: String { get }
    func getPermittedResponses(completion: @escaping (F4SNetworkResult<F4SCannedResponses>) -> ())
}

public class F4SCannedMessageResponsesService : F4SDataTaskService {
    
    public let threadUuid: String
    
    public init(threadUuid: F4SUUID) {
        self.threadUuid = threadUuid
        let apiName = "messaging/\(threadUuid)/possible_responses"
        super.init(baseURLString: Config.BASE_URL2, apiName: apiName)
    }
}

extension F4SCannedMessageResponsesService : F4SCannedMessageResponsesServiceProtocol {
    
    public func getPermittedResponses(completion: @escaping (F4SNetworkResult<F4SCannedResponses>) -> ()) {
        beginGetRequest(attempting: "Get message options for thread", completion: completion)
    }
}







