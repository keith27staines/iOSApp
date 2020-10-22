
import WorkfinderCommon
import WorkfinderServices

protocol ProjectAndAssociationDetailsServiceProtocol {
    func fetch(projectUuid: F4SUUID, completion: @escaping (Result<ProjectAndAssociationDetail, Error>) -> Void)
}

class ProjectAndAssociationDetailsService: ProjectAndAssociationDetailsServiceProtocol {
    
    var projectAndAssociationDetail = ProjectAndAssociationDetail()
    var projectService: ProjectServiceProtocol
    var associationDetailService: AssociationDetailService
    var completion: ((Result<ProjectAndAssociationDetail, Error>) -> Void)?
    
    init(networkConfig: NetworkConfig) {
        associationDetailService = AssociationDetailService(networkConfig: networkConfig)
        projectService = ProjectService(networkConfig: networkConfig)
    }
    
    func fetch(projectUuid: F4SUUID, completion: @escaping (Result<ProjectAndAssociationDetail, Error>) -> Void) {
        self.completion = completion
        loadProject(projectUuid: projectUuid)
    }
    
    private func loadProject(projectUuid: F4SUUID) {
        projectService.fetchProject(uuid: projectUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let project):
                self.onProjectDidLoad(project: project)
            case .failure(let error):
                guard (error as? WorkfinderError)?.retry == true else {
                    self.completion?(Result<ProjectAndAssociationDetail, Error>.failure(error))
                    return
                }
                self.loadProject(projectUuid: projectUuid)
            }
        }
    }
    
    private func onProjectDidLoad(project: ProjectJson) {
        projectAndAssociationDetail.project = project
        guard let associationUuid = project.association else { return }
        loadAssociationDetail(associationUuid: associationUuid)
    }
    
    private func loadAssociationDetail(associationUuid: F4SUUID) {
        associationDetailService.fetchAssociationDetail(associationUuid: associationUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let detail):
                self.onAssociationDetailLoaded(associationDetail: detail)
            case .failure(let error):
                guard (error as? WorkfinderError)?.retry == true else {
                    self.completion?(Result<ProjectAndAssociationDetail, Error>.failure(error))
                    return
                }
                self.loadAssociationDetail(associationUuid: associationUuid)
            }
        }
    }
    
    private func onAssociationDetailLoaded(associationDetail: AssociationDetail) {
        projectAndAssociationDetail.associationDetail = associationDetail
        completion?(Result<ProjectAndAssociationDetail, Error>.success(projectAndAssociationDetail))
    }

    
}

