
public struct ProjectAndAssociationDetail {
    public var project: ProjectJson?
    public var projectType: String? { project?.type }
    public var associationDetail: AssociationDetail?
    public init() {}
}
