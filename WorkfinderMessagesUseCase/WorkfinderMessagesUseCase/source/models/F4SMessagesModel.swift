
import Foundation
import WorkfinderCommon

public typealias F4SMessagesModelResult = F4SNetworkResult<F4SMessagesModel>

public class F4SMessageModelBuilder {
    
    let threadUuid: F4SUUID
    
    let messageService: F4SMessageServiceProtocol
    let messageActionService: F4SMessageActionServiceProtocol
    let messageCannedResponseService: F4SCannedMessageResponsesServiceProtocol
    
    public init(threadUuid: F4SUUID,
                messageService: F4SMessageServiceProtocol,
                messageActionService: F4SMessageActionServiceProtocol,
                messageCannedResponseService: F4SCannedMessageResponsesServiceProtocol) {
        self.threadUuid = threadUuid
        self.messageService = messageService
        self.messageActionService = messageActionService
        self.messageCannedResponseService = messageCannedResponseService
    }
    
    var messagesModel: F4SMessagesModel!
    public func build(threadUuid: F4SUUID, completion: @escaping (F4SMessagesModelResult) -> Void) {
        messagesModel = F4SMessagesModel(threadUuid: threadUuid)
        let result = F4SMessagesModelResult.success(messagesModel)
        addMessages(threadUuid: threadUuid, messagesResult: result) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(let error):
                completion(F4SMessagesModelResult.error(error))
            case .success(_):
                strongSelf.addCannedResponses(threadUuid: threadUuid, messagesResult: result) { (result) in
                    switch result {
                    case .error(let error):
                        completion(F4SMessagesModelResult.error(error))
                    case .success(_):
                        strongSelf.addAction(threadUuid: threadUuid, messagesResult: result) { (result) in
                            completion(result)
                        }
                    }
                }
            }
        }
    }
    
    internal func addMessages(threadUuid: F4SUUID, messagesResult: F4SMessagesModelResult, completion: @escaping (F4SMessagesModelResult) -> ()) {
        switch messagesResult {
        case .error(_):
            completion(messagesResult)
        case .success(var model):
            messageService.getMessages { result in
                switch result {
                case .error(let error):
                    completion(F4SMessagesModelResult.error(error))
                case .success(let result):
                    model.messages = result.messages
                    completion(F4SMessagesModelResult.success(model))
                }
            }
        }
    }
    
    internal func addAction(threadUuid: F4SUUID, messagesResult: F4SMessagesModelResult, completion: @escaping (F4SMessagesModelResult) -> ()) {
        switch messagesResult {
        case .error(_):
            completion(messagesResult)
        case .success(var model):
            messageActionService.getMessageAction { result in
                switch result {
                case .error(let error):
                    completion(F4SMessagesModelResult.error(error))
                case .success(let result):
                    model.action = result
                    completion(F4SMessagesModelResult.success(model))
                }
            }
        }
    }
    
    internal func addCannedResponses(threadUuid: F4SUUID, messagesResult: F4SMessagesModelResult, completion: @escaping (F4SMessagesModelResult) -> ()) {
        switch messagesResult {
        case .error(_):
            completion(messagesResult)
        case .success(var model):
            guard model.action?.actionType == nil else {
                // If the action is set, canned responses are not expected and may error, so just return what we have already
                completion(messagesResult)
                return
            }
            messageCannedResponseService.getPermittedResponses { result in
                switch result {
                case .error(let error):
                    completion(F4SMessagesModelResult.error(error))
                case .success(let result):
                    model.cannedResponses = result
                    completion(F4SMessagesModelResult.success(model))
                }
            }
        }
    }
    
}

public struct F4SMessagesModel : Codable {
    public var threadUuid: F4SUUID?
    public var messages: [F4SMessage]?
    public var cannedResponses: F4SCannedResponses?
    public var action: F4SAction?
    
    public init(threadUuid: F4SUUID? = nil, messages: [F4SMessage]? = nil, cannedResponses: F4SCannedResponses? = nil, action: F4SAction? = nil) {
        self.threadUuid = threadUuid
        self.messages = messages
        self.cannedResponses = cannedResponses
        self.action = action
    }
}














