import Foundation

public struct PicklistServerJson: Codable {
    var next: String?
    var previous: String?
    var results: [PicklistItemJson]
}

public struct PicklistItemJson: Codable {
    var uuid: String?
    var value: String?
    public init(uuid: String, value: String) {
        self.uuid = uuid
        self.value = value
    }
}

extension PicklistItemJson {
    private enum codingKeys: String, CodingKey {
        case uuid
        case value = "display_name"
    }
}

extension Picklist.PicklistType {
    var endpoint: String {
        switch self {
        case .roles: return "job-roles/"
        case .skills: return "employment-skills/"
        case .attributes: return "personal-attributes/"
        case .universities: return "institutions/"
        }
    }
}




