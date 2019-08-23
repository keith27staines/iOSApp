import Foundation

public struct F4SRoleJson : Codable {
    public var uuid: F4SUUID?
    public var name: String?
    public var description: String?
    public init(uuid: F4SUUID, name: String?, description: String?) {
        self.uuid = uuid
        self.name = name
        self.description = description
    }
}
