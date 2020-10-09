
protocol AboutPresenterProtocol: CellPresenterProtocol {
    var text: String { get }
}

class AboutPresenter: AboutPresenterProtocol {

    let text: String
    
    init(text: String?, defaultText: String) {
        guard let text = text, !text.isEmpty else {
            self.text = defaultText
            return
        }
        self.text = text
    }
}
