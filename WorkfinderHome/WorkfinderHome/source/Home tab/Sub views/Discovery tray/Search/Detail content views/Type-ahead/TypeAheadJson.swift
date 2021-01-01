
struct TypeAheadJson : Codable {
    var count: Int
    var projects: [TypeAheadItem]?
    var companies: [TypeAheadItem]?
    var people: [TypeAheadItem]?
    
    private enum CodingKeys: String, CodingKey {
        case count
        case projects
        case companies
        case people = "associations"
    }
}
