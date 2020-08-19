
public struct AssociationDetail: Codable {
    public var association: AssociationJson?
    public var location: CompanyLocationJson?
    public var host: Host?
    public var title: String? { association?.title }
    public var company: CompanyJson?
    
    public var isComplete: Bool {
        association != nil && location != nil && host != nil && company != nil
    }
    
    public init() {}
}
