
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
    var projectService: ProjectServiceProtocol
    var project: ProjectJson?
    var projectType: ProjectTypeJson?
    var associationDetailService: AssociationDetailService
    
    lazy var projectDescription: String? = "loading \(projectUuid)"
    
    init(coordinator: ProjectApplyCoordinator,
         projectUuid: F4SUUID,
         projectService: ProjectServiceProtocol,
         associationDetailService: AssociationDetailService) {
        self.coordinator = coordinator
        self.projectUuid = projectUuid
        self.projectService = projectService
        self.associationDetailService = associationDetailService
    }
    
    func onViewDidLoad(view: ProjectViewProtocol) {
        self.view = view
    }
    
    var loadCompletion: ((Error?) -> Void)?
    
    func loadData(completion: @escaping (Error?) -> Void) {
        self.loadCompletion = completion
        loadProject()
    }
    
    private func loadProject() {
        projectService.fetchProject(uuid: projectUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let project):
                self.project = project
                self.onProjectDidLoad()
            case .failure(let error):
                self.loadCompletion?(error)
            }
        }
    }
    
    private func onProjectDidLoad() {
        guard let uuid = self.project?.type else { return }
        loadProjectType(uuid)
    }
    
    private func loadProjectType(_ uuid: F4SUUID) {
        projectService.fetchProjectType(uuid: uuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let projectType):
                self.projectType = projectType
                self.onProjectTypeDidLoad()
            case .failure(let error):
                self.loadCompletion?(error)
            }
        }
    }
    
    private func onProjectTypeDidLoad() {
        projectDescription = "project \(projectUuid) loaded\nproject type: \(projectType?.name ?? "unknown")"
        loadCompletion?(nil)
    }
}
