
import WorkfinderCommon

class ProjectPresenter {
    let projectUuid: F4SUUID
    let projectService: ProjectServiceProtocol
    
    init(projectUuid: F4SUUID, projectService: ProjectServiceProtocol) {
        self.projectUuid = projectUuid
        self.projectService = projectService
    }
    
}
