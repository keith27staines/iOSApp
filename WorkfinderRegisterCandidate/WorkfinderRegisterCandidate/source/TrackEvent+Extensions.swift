
import WorkfinderCommon

extension TrackingEvent {
    static func registerUser() -> TrackingEvent {
        TrackingEvent(type: .registerUser, additionalProperties: [
            "user_type": "candidate",
            "auth_type": "email"
        ])
    }
    
    static func signInUser() -> TrackingEvent {
        TrackingEvent(type: .signInUser, additionalProperties: [
            "user_type": "candidate",
            "auth_type": "email"
        ])
    }
}
