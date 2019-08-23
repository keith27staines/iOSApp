import Foundation

public protocol RecommendationProtocol {
    /// Required sort index
    var index: Int { get }
    /// the company uuid
    var uuid: F4SUUID? { get }
}

public struct Recommendation : Codable , Hashable, Equatable, RecommendationProtocol {
    public static func == (lhs: Recommendation, rhs: Recommendation) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    /// Required sort index
    public let index: Int
    
    /// the company uuid
    public let uuid: F4SUUID?
    
    public init(companyUUID: F4SUUID, sortIndex: Int) {
        self.index = sortIndex
        self.uuid = companyUUID.dehyphenated
    }
    
    public init(recommendation: RecommendationProtocol) {
        self.index = recommendation.index
        self.uuid = recommendation.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid ?? "")
    }
}
