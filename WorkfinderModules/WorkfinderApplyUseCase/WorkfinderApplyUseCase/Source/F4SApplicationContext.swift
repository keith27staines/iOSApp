import Foundation
import WorkfinderCommon

public struct F4SApplicationContext {
    public var user: F4SUser?
    public var companyWorkplace: CompanyWorkplace?
    public var host: F4SHost?
    
    public init(user: F4SUser? = nil, companyWorkplace: CompanyWorkplace? = nil, host: F4SHost? = nil) {
        self.user = user
        self.companyWorkplace = companyWorkplace
        self.host = host
    }
}
