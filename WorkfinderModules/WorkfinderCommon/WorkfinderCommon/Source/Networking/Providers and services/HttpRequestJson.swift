
import Foundation

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
