    import UIKit
    
    public enum UploadScenario {
        case applyWorkflow
    }
    
    extension UploadScenario {
        var headingText: String {
            switch self {
            case .applyWorkflow:
                return "Stand out from the crowd!"
            }
        }
        
        var subheadingText: String {
            switch self {
            case .applyWorkflow:
                return "Add your CV or any supporting document to make it easier for companies to choose you"
            }
        }
        
        var bigPlusButtonIsHidden: Bool {
            switch self {
            case .applyWorkflow:
                return false
            }
        }
    }

