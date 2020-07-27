

public struct TemplateModel : Codable {
    public var uuid: String
    public var templateString: String
    public var isProject: Bool?
    public var minimumAge: Int?
    
    public init(uuid: String, templateString: String, isProject: Bool, minimumAge: Int) {
        self.uuid = uuid
        self.templateString = templateString
        self.minimumAge = minimumAge
        self.isProject = isProject
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case templateString = "template"
        case isProject = "is_project"
        case minimumAge = "minimum_age"
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

