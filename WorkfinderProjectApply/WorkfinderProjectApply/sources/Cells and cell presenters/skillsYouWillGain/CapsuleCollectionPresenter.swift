
protocol CapsuleCollectionPresenterProtocol: CellPresenterProtocol {
    var strings: [String] { get }
}


class CapsuleCollectionPresenter: CapsuleCollectionPresenterProtocol {
    let strings: [String]
    init(strings: [String]) {
        self.strings = strings
    }
}
