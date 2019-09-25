public struct F4SUserStatus : Codable {
    public var unreadMessageCount: Int
    public var unratedPlacements: [F4SUUID]
    public init(unreadMessageCount: Int, unratedPlacements: [F4SUUID]) {
        self.unreadMessageCount = unreadMessageCount
        self.unratedPlacements = unratedPlacements
    }
}

private extension F4SUserStatus {
    private enum CodingKeys : String, CodingKey {
        case unreadMessageCount = "unread_count"
        case unratedPlacements = "unrated"
    }
}
