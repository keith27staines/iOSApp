
protocol SectionHeadingPresenterProtocol: CellPresenterProtocol {
    var title: String { get }
}

class SectionHeadingPresenter: SectionHeadingPresenterProtocol {
    let title: String
    init(title: String) {
        self.title = title
    }
}
