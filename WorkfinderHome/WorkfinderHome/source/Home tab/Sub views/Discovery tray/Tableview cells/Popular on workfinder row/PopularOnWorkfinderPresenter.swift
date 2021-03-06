
import WorkfinderCommon
import WorkfinderUI

protocol SectionPresenterProtocol {
    func cellPresenterForRow(_ row: Int) -> CellPresenterProtocol
}

class PopularOnWorkfinderPresenter: SectionPresenterProtocol {
    weak var userMessageHandler: HSUserMessageHandler?
    var capsulesData: [CapsuleData] = [
        CapsuleData(id: UUID().uuidString, title: "Marketing"),
        CapsuleData(id: UUID().uuidString, title: "Two week placement", searchText: ""),
        CapsuleData(id: UUID().uuidString, title: "Social media"),
        CapsuleData(id: UUID().uuidString, title: "Testing"),
        CapsuleData(id: UUID().uuidString, title: "Design"),
        CapsuleData(id: UUID().uuidString, title: "Sales"),
        CapsuleData(id: UUID().uuidString, title: "Product")
    ]
    
    func cellPresenterForRow(_ row: Int) -> CellPresenterProtocol {
        capsulesData
    }
    
    init(messageHandler: HSUserMessageHandler?) {
        self.userMessageHandler = messageHandler
    }
}

extension Array: CellPresenterProtocol where Element == CapsuleData {}

struct CapsuleData {
    var id: F4SUUID
    var title: String
    var searchText: String
    
    init(id: String, title: String, searchText: String? = nil) {
        self.id = id
        self.title = title
        self.searchText = searchText ?? title
    }
}
