
import Foundation
import WorkfinderCommon

public struct ProjectJson: Codable, Equatable {
    var uuid: F4SUUID?
    var type: F4SUUID?
    var association: F4SUUID?
    var isPaid: Bool?
    var candidateQuantity: String?
    var isRemote: Bool?
    var duration: String
    
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
