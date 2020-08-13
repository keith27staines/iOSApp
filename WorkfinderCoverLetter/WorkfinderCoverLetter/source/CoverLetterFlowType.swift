
public enum CoverLetterFlowType {
    case passiveApplication
    case projectApplication
    
    var name: String {
        switch self {
        case .passiveApplication: return "passive"
        case .projectApplication: return "project"
        }
    }
}
