
protocol ProjectBulletPointsPresenterProtocol: CellPresenterProtocol {
    var title: String { get }
    var text: String { get }
}

class ProjectBulletPointsPresenter: ProjectBulletPointsPresenterProtocol {
    let title: String
    let text: String
    var isHidden: Bool
    init(title: String, text: String, isHidden: Bool = false) {
        self.title = title
        self.text = text
        self.isHidden = isHidden
    }
}
