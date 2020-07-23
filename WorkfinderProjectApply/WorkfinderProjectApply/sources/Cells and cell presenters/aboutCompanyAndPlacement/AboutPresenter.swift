
protocol AboutPresenterProtocol: CellPresenterProtocol {
    var text: String { get }
}

class AboutPresenter: AboutPresenterProtocol {

    let text: String
    
    init(text: String) {
        self.text = text
    }
}
