//
//  MessageDispatcher.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import UIKit


public enum F4SActionValidatorError : Error {
    case argumentMissing
}

public struct F4SActionValidator {
    
    public static func validate(action: F4SAction) throws {
        
        switch action.actionType {
        case .uploadDocuments:
            guard let _ = action.argument(name: .placementUuid),
                let _ = action.argument(name: .documentType) else {
                throw F4SActionValidatorError.argumentMissing
            }
        }
    }
    
}
