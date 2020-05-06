
import Foundation

public struct PicklistItemJson: Codable {
    public var uuid: String?
    public var value: String?
    public var name: String?
    public var guaranteedUuid: String { return uuid ?? (name ?? UUID().uuidString) }
    public var guarenteedName: String { return value ?? (name ?? "unnamed item") }
    public var otherValue: String?
    public init(uuid: String, value: String) {
        self.uuid = uuid
        self.value = value
    }
    
    private enum codingKeys: String, CodingKey {
        case uuid
        case value = "display_name"
        case name
    }
}
