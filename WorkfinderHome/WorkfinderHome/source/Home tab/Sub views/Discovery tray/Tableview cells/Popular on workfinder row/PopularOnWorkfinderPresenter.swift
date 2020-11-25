
import WorkfinderCommon

class PopularOnWorkfinderPresenter: CellPresenter {
    var capsulesData: [CapsuleData] = [
        CapsuleData(id: UUID().uuidString, text: "Capsule 1"),
        CapsuleData(id: UUID().uuidString, text: "Capsule 2"),
        CapsuleData(id: UUID().uuidString, text: "Capsule 3"),
        CapsuleData(id: UUID().uuidString, text: "Capsule 4"),
        CapsuleData(id: UUID().uuidString, text: "Capsule 5"),
        CapsuleData(id: UUID().uuidString, text: "Capsule 6"),
        CapsuleData(id: UUID().uuidString, text: "Capsule 7"),
        CapsuleData(id: UUID().uuidString, text: "Capsule 8"),
        CapsuleData(id: UUID().uuidString, text: "Capsule 9"),
    ]
}

struct CapsuleData {
    var id: F4SUUID
    var text: String
}
