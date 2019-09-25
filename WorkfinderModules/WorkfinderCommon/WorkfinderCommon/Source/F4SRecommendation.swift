import Foundation

public protocol F4SRecommendationProtocol {
    /// Required sort index
    var index: Int { get }
    /// the company uuid
    var uuid: F4SUUID? { get }
}

public struct F4SRecommendation : Codable , Hashable, Equatable, F4SRecommendationProtocol {
    public static func == (lhs: F4SRecommendation, rhs: F4SRecommendation) -> Bool {
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
    
    public init(recommendation: F4SRecommendationProtocol) {
        self.index = recommendation.index
        self.uuid = recommendation.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid ?? "")
    }
}
