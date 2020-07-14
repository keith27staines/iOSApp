
import WorkfinderCommon
import WorkfinderServices

protocol ProjectPresenterProtocol {
    var projectDescription: String? { get }
    func loadData(completion: @escaping (Error?) -> Void)
    func onViewDidLoad(view: ProjectViewProtocol)
}

class ProjectPresenter: ProjectPresenterProtocol {
    
    weak var coordinator: ProjectApplyCoordinator?
    weak var view: ProjectViewProtocol?
    let projectUuid: F4SUUID
    let service: ProjectAndAssociationDetailsServiceProtocol
    
    var detail = ProjectAndAssociationDetail() {
        didSet {
            projectDescription = "Loaded project \(detail.project?.uuid ?? "load error" )"
            view?.refreshFromPresenter()
        }
    }
    
    var projectDescription: String?
    
    init(coordinator: ProjectApplyCoordinator,
         projectUuid: F4SUUID,
         projectService: ProjectAndAssociationDetailsServiceProtocol) {
        self.coordinator = coordinator
        self.projectUuid = projectUuid
        self.service = projectService
        projectDescription = "loading \(projectUuid)"
    }
    
    func onViewDidLoad(view: ProjectViewProtocol) {
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        service.fetch(projectUuid: projectUuid) { (result) in
            switch result {
            case .success(let detail):
                self.detail = detail
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
