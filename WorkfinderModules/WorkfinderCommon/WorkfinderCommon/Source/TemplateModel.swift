

public struct TemplateModel : Codable {
    public var uuid: String
    public var templateString: String
    public var isProject: Bool?
    public var minimumAge: Int?
    public var isDefault: Bool?
    
    public init(uuid: String, templateString: String, isProject: Bool, minimumAge: Int, isDefault: Bool = false) {
        self.uuid = uuid
        self.templateString = templateString
        self.minimumAge = minimumAge
        self.isProject = isProject
        self.isDefault = isDefault
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case templateString = "template"
        case isProject = "is_project"
        case minimumAge = "minimum_age"
        case isDefault = "is_default"
    }
}

public struct TemplateField {
    
    public enum DelimiterType: String {
        case start = "{{"
        case end = "}}"
    }
    
    public let name: String
    public var range: Range<String.Index>?
    
    public init(name: String) {
        self.name = name
    }
}

