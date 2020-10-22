
public struct ProjectTypeJson: Codable, Equatable {
    public var uuid: String?
    public var readMoreUrl: String?
    public var icon: String?

    enum CodingKeys: String, CodingKey {
        case uuid
        case readMoreUrl = "read_more_url"
        case icon
    }
}

public struct UUIDAndNameJson: Codable, Equatable {
    public var uuid: String?
    public var name: String?
}
