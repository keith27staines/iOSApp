
public struct AssociationDetail: Codable, Equatable, Hashable {
    public var uuid: F4SUUID?
    public var association: AssociationJson?
    public var location: CompanyLocationJson?
    public var host: Host?
    public var title: String? { association?.title }
    public var company: CompanyJson? //{ association?.location.company }
    
    public var isComplete: Bool {
        association != nil && location != nil && host != nil && company != nil
    }
    
    public init() {}
}
