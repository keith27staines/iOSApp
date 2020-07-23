
protocol CapsulePresenterProtocol: CellPresenterProtocol {
    var text: String { get }
}


class CapsulePresenter: CapsulePresenterProtocol {
    let text: String
    init(text: String) {
        self.text = text
    }
}
