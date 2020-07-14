
import WorkfinderCommon

struct AssociationDetail: Codable {
    var association: AssociationJson?
    var location: CompanyLocationJson?
    var host: Host?
    var company: CompanyJson?
    
    var isComplete: Bool {
        association != nil && location != nil && host != nil && company != nil
    }
}
