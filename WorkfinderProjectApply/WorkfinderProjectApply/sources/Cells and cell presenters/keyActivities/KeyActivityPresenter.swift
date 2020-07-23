
protocol KeyActivityPresenterProtocol: CellPresenterProtocol {
    var text: String? { get }
}


class KeyActivityPresenter: KeyActivityPresenterProtocol {
    let text: String?
    init(activity: String?) {
        self.text = activity
    }
}
