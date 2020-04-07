/*
{
  "count": 123,
  "next": "string",
  "previous": "string",
  "results": [
    {
      "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "template_string": "string",
      "minimum_age": 0
    }
  ]
}
 */
import WorkfinderCommon

public struct TemplateField {
    
    public enum DelimiterType: String {
        case start = "{{"
        case end = "}}"
    }
    
    let name: String
    var range: Range<String.Index>?
    
    public init(name: String) {
        self.name = name
    }
}

public struct TemplateModel : Codable {
    var uuid: String
    var templateString: String
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case templateString = "template_string"
    }
}

public struct TemplateListJson: Codable {
    var results: [TemplateModel]
}
