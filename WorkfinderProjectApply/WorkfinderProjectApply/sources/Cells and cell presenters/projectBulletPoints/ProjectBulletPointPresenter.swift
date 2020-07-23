
protocol ProjectBulletPointsPresenterProtocol: CellPresenterProtocol {
    var title: String { get }
    var text: String { get }
}

class ProjectBulletPointsPresenter: ProjectBulletPointsPresenterProtocol {
    let title: String
    let text: String
    init(title: String, text: String) {
        self.title = title
        self.text = text
    }
}
