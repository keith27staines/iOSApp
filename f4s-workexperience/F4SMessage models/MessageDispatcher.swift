import Foundation
import WorkfinderCommon

public enum F4SActionValidatorError : Error {
    case missingActionType
    case missingArgument
}

public struct F4SActionValidator {
    
    public static func validate(action: F4SAction) throws {
        guard let actionType = action.actionType else {
            throw F4SActionValidatorError.missingActionType
        }
        switch actionType {
        case .uploadDocuments:
            guard let _ = action.argument(name: .placementUuid),
                let _ = action.argument(name: .documentType) else {
                throw F4SActionValidatorError.missingArgument
            }
        case .viewOffer:
            guard let _ = action.argument(name: .placementUuid) else {
                    throw F4SActionValidatorError.missingArgument
            }
        case .viewCompanyExternalApplication:
            guard let _ = action.argument(name: .placementUuid) else {
                throw F4SActionValidatorError.missingArgument
            }
        }
    }
    
}
