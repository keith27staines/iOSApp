
import Foundation
import WorkfinderCommon

extension F4SHost {

    static func makeHosts() -> [F4SHost] {
        return [
            F4SHost(
                uuid: "1",
                displayName: "Alex Farrell",
                firstName: "Alex",
                lastName: "Farrell",
                profileUrl: "https://www.bbc.co.uk",
                imageUrl: "person1",
                role: "CEO"),
            F4SHost(
                uuid: "2",
                displayName: "Albert Einstein",
                firstName: "Albert",
                lastName: "Einstein",
                profileUrl: nil,
                imageUrl: "person2",
                role: "Accountant"),
            F4SHost(
                uuid: "3",
                displayName: "Marie Curie",
                firstName: "Marie",
                lastName: "Curie",
                profileUrl: nil,
                imageUrl: "person2",
                role: "Developer"),
            F4SHost(
                uuid: "4",
                displayName: "Mary Shelley",
                firstName: "Mary",
                lastName: "Shelley",
                profileUrl: nil,
                imageUrl: "person2",
                role: "Human resources manager"),
        ]
    }
}





