//
//  F4SVoucherLogic.swift
//  WorkfinderAppLogic
//
//  Created by Keith Dev on 31/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

public class F4SVoucherLogic {
    
    var service: F4SVoucherVerificationServiceProtocol?
    
    public enum CodeValidationError: Error {
        case networkError
        case alreadyUsed
        case invalid
        case other
    }
    public enum State {
        case invalidOnClient
        case validOnClient
        case unknownOnServer
        case alreadyUsed
        case available
    }
    
    public var placement: F4SUUID = ""
    public var code: String = ""
    public var state: State = .invalidOnClient
    
    public init(placement: F4SUUID, code: String = "") {
        self.placement = placement
        self.code = code
        state = .invalidOnClient
    }
    
    public func passesClientsideRules() -> Bool {
        return code.count == 6
    }
    
    public func cancelServerValidation() {
        service?.cancel()
    }
    
    public func validateOnServer(completion: @escaping (CodeValidationError?)->()) {
        cancelServerValidation()
        if placement.isEmpty || code.isEmpty { return }
        let service = F4SVoucherVerificationService(placementUuid: placement, voucherCode:  code)
        service.verify(completion: { (result) in
            DispatchQueue.main.async {
                switch result {
                case .error(let error):
                    if error.retry {
                        completion(CodeValidationError.networkError)
                    } else {
                        completion(CodeValidationError.other)
                    }
                    
                case .success(let verificationResult):
                    if verificationResult.errors == nil{
                        completion(nil)
                    } else {
                        completion(CodeValidationError.alreadyUsed)
                    }
                }
            }
        })
        self.service = service
    }
    
    public static var allowedSymbols: CharacterSet {
        return CharacterSet.alphanumerics
    }
    
    public static var disallowedSymbols: CharacterSet {
        return CharacterSet.alphanumerics.inverted
    }
    
    public func setStateFromServerCodeValidationError(error: CodeValidationError) {
        switch error {
        case .networkError:
            // Show retry alert
            state = F4SVoucherLogic.State.unknownOnServer
            break
        case .alreadyUsed:
            state = F4SVoucherLogic.State.alreadyUsed
            break
        case .invalid:
            state = F4SVoucherLogic.State.unknownOnServer
            break
        case .other:
            state = F4SVoucherLogic.State.unknownOnServer
            break
        }
        return
    }
}
