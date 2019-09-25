import Foundation

public struct Shortlist : Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(companyUuid)
    }
    
    public static func ==(lhs: Shortlist, rhs: Shortlist) -> Bool {
        return lhs.companyUuid == rhs.companyUuid
    }
    
    public var companyUuid: String
    public var uuid: String
    public var date: Date
    
    public init(companyUuid: String = "", uuid: String = "", date: Date = Date()) {
        self.companyUuid = companyUuid
        self.uuid = uuid
        self.date = date
    }
}
