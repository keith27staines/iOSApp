
import WorkfinderCommon

class PopularOnWorkfinderPresenter: CellPresenter {
    var capsulesData: [CapsuleData] = [
        CapsuleData(id: UUID().uuidString, text: "Marketing"),
        CapsuleData(id: UUID().uuidString, text: "Two week placement"),
        CapsuleData(id: UUID().uuidString, text: "Social media"),
        CapsuleData(id: UUID().uuidString, text: "Testing"),
        CapsuleData(id: UUID().uuidString, text: "Design"),
        CapsuleData(id: UUID().uuidString, text: "Sales"),
        CapsuleData(id: UUID().uuidString, text: "Product")
    ]
}

struct CapsuleData {
    var id: F4SUUID
    var text: String
}
