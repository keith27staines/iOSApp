
import WorkfinderCommon

enum ApplicationAction {
    case viewApplication(placementUuid: F4SUUID)
    case viewOffer(placementUuid: F4SUUID)
    case viewInterview(interviewId: Int)
    case joinInterview(link: String)
}
