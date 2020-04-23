
import Foundation

public struct PicklistServerJson: Codable {
    public var next: String?
    public var previous: String?
    public var results: [PicklistItemJson]
}

public struct PicklistItemJson: Codable {
    public var uuid: String?
    public var value: String?
    public init(uuid: String, value: String) {
        self.uuid = uuid
        self.value = value
    }
    
    private enum codingKeys: String, CodingKey {
        case uuid
        case value = "display_name"
    }
}
