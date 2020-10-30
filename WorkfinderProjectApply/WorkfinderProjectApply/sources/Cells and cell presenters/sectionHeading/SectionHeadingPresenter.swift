
protocol SectionHeadingPresenterProtocol: CellPresenterProtocol {
    var title: String { get }
}

class SectionHeadingPresenter: SectionHeadingPresenterProtocol {
    let title: String
    var isHidden: Bool
    init(title: String, isHidden: Bool = false) {
        self.title = title
        self.isHidden = isHidden
        
    }
}
