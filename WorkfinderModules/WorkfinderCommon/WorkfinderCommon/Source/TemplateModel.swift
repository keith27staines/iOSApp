public struct TemplateListJson: Codable {
    public var results: [TemplateModel]
    public init(results: [TemplateModel]) {
        self.results = results
    }
    
}

public struct TemplateModel : Codable {
    public var uuid: String
    public var templateString: String
    
    public init(uuid: String, templateString: String) {
        self.uuid = uuid
        self.templateString = templateString
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case templateString = "template_string"
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

