
public struct ProjectJson: Codable, Equatable, Hashable {
    public var uuid: F4SUUID?
    public var type: F4SUUID?
    public var association: F4SUUID?
    public var isPaid: Bool?
    public var status: String?
    public var candidateQuantity: String?
    public var additionalComments: String?
    public var isRemote: Bool?
    public var duration: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case type
        case association
        case isPaid = "is_paid"
        case status
        case candidateQuantity = "candidate_quantity"
        case isRemote = "is_remote"
        case additionalComments = "additional_comments"
        case duration
    }
}
