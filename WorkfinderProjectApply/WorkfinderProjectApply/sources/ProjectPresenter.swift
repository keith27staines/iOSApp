
import WorkfinderCommon

class ProjectPresenter {
    weak var coordinator: ProjectApplyCoordinator?
    let projectUuid: F4SUUID
    let projectService: ProjectServiceProtocol
    
    init(coordinator: ProjectApplyCoordinator,
         projectUuid: F4SUUID,
         projectService: ProjectServiceProtocol) {
        self.coordinator = coordinator
        self.projectUuid = projectUuid
        self.projectService = projectService
    }
    
}
