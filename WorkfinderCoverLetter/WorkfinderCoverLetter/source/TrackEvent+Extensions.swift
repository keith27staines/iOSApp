
import WorkfinderCommon

enum CoverLetterEventType {
    case letterPreview
    case letterEditor
    case questionOpened(PicklistType)
    case questionClosed(PicklistType)
    
    var name: String {
        switch self {
        case .letterPreview: return "projectApplyPreview"
        case .letterEditor: return "projectApplyEdit"
        case .questionOpened: return "projectApplyNext"
        case .questionClosed: return "projectApplyBack"
        }
    }
    
    var trackEventType: TrackEventType {
        switch self {
        case .letterPreview: return .projectApplyPreview
        case .letterEditor: return .projectApplyEdit
        case .questionOpened(_): return .projectApplyNext
        case .questionClosed(_): return .projectApplyBack
        }
    }
}

extension TrackingEvent {
    static func event(type: CoverLetterEventType, flow: CoverLetterFlowType) -> TrackingEvent {
        var properties: [String: String] =  ["application_type" : flow.name]
        switch type {
        case .questionOpened(let picklistType):
            properties["step_number"] = picklistType.trackingCode
        case .questionClosed(let picklistType):
            properties["step_number"] = picklistType.trackingCode
        default:
            break
        }
        return TrackingEvent(type: type.trackEventType, additionalProperties: properties)
    }
}
