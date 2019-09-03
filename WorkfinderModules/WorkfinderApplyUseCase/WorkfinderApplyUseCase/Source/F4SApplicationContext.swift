import Foundation
import WorkfinderCommon

public struct F4SApplicationContext {
    public var user: F4SUser?
    public var company: Company?
    public var placement: F4SPlacement?
    
    public init(user: F4SUser? = nil, company: Company? = nil, placement: F4SPlacement? = nil) {
        self.user = user
        self.company = company
        self.placement = placement
    }
}
