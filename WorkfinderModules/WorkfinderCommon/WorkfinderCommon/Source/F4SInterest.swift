import Foundation

/// An instance of F4SInterest represents of either a YP or a company and
/// is used to try to match YPs with companies
public struct F4SInterest : Codable {
    public static func ==(lhs: F4SInterest, rhs: F4SInterest) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public var uuid: F4SUUID
    /// User-facing name or description of the interest
    public var name: String
    
    /// Initialises a new instance
    ///
    /// - Parameters:
    ///   - id: The database id
    ///   - uuid: Identifies the interest (used in matching YPs to companies)
    ///   - name: Yser-facing name of the interest
    public init(uuid: F4SUUID = "", name: String = "") {
        self.uuid = uuid
        self.name = name
    }
}

extension F4SInterest {
    private enum CodingKeys : String, CodingKey {
        case uuid
        case name
    }
}

extension F4SInterest : Hashable {
    /// The hash operates purely on the UUID
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

public extension Sequence where Iterator.Element == F4SInterest {
    /// Converts a sequence of interests into an array of interest uuids
    var uuidList: [F4SUUID] {
        return map({ (interest) -> F4SUUID in
            interest.uuid
        })
    }
}
