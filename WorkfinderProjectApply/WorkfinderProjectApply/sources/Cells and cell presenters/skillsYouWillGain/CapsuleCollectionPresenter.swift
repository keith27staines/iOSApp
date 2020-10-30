
protocol CapsuleCollectionPresenterProtocol: CellPresenterProtocol {
    var strings: [String] { get }
}


class CapsuleCollectionPresenter: CapsuleCollectionPresenterProtocol {
    let strings: [String]
    var isHidden: Bool
    init(strings: [String]) {
        self.strings = strings
        isHidden = strings.isEmpty
    }
}
