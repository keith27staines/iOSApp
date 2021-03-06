
protocol AboutPresenterProtocol: CellPresenterProtocol {
    var text: String { get }
}

class AboutPresenter: AboutPresenterProtocol {

    let text: String
    var isHidden: Bool
    init(text: String?, defaultText: String, isHidden: Bool = false) {
        self.isHidden = isHidden
        guard let text = text, !text.isEmpty else {
            self.text = defaultText
            return
        }
        self.text = text
    }
}
