    import UIKit
    
    public enum UploadScenario {
        case applyWorkflow
        case businessLeaderRequest(F4SBusinessLeadersRequestModel)
    }
    
    extension UploadScenario {
        var headingText: String {
            switch self {
            case .applyWorkflow:
                return "Stand out from the crowd!"
            case .businessLeaderRequest:
                return "Add requested information"
            }
        }
        
        var subheadingText: String {
            switch self {
            case .applyWorkflow:
                return "Add your CV or any supporting document to make it easier for companies to choose you"
            case .businessLeaderRequest(let requestModel):
                return "Add the documents requested by \(requestModel.companyName) in their recent message to you"
            }
        }
        
        var bigPlusButtonIsHidden: Bool {
            switch self {
            case .applyWorkflow:
                return false
            case .businessLeaderRequest:
                return true
            }
        }
    }

