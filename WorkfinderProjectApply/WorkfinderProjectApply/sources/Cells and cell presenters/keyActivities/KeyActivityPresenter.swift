
protocol KeyActivityPresenterProtocol: CellPresenterProtocol {
    var text: String? { get }
}


class KeyActivityPresenter: KeyActivityPresenterProtocol {
    let text: String?
    var isHidden: Bool
    init(activity: String?, isHidden: Bool = false) {
        self.text = activity
        self.isHidden = isHidden
    }
}
