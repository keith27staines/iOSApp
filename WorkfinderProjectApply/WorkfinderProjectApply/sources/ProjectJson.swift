
import Foundation
import WorkfinderCommon

public struct ProjectJson: Codable, Equatable {
    public var uuid: F4SUUID?
    public var type: F4SUUID?
    public var association: F4SUUID?
    public var isPaid: Bool?
    public var candidateQuantity: String?
    public var isRemote: Bool?
    public var duration: String
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case type
        case association
        case isPaid = "is_paid"
        case candidateQuantity = "candidate_quantity"
        case isRemote = "is_remote"
        case duration
    }
}
