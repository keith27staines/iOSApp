
import WorkfinderCommon

struct TypeAheadItem: Codable {
    var uuid: String?
    var title: String?
    var subtitle: String?
    var searchTerm: String?
    var objectType: String?
    var iconUrlString: String?
    var applicationSource: AppSource = .unspecified
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case title = "name"
        case subtitle = "label"
        case searchTerm = "search_term"
        case objectType = "object_type"
        case iconUrlString = "icon"
    }
    
    func settingApplicationSource(_ applicationSource: AppSource) -> TypeAheadItem {
        var item = self
        item.applicationSource = applicationSource
        return item
    }
}
