
import WorkfinderCommon

class HostViewPresenter {
    let coordinator: ApplicationsCoordinator
    let locationService: AssociationsServiceProtocol
    let hostService: HostsProviderProtocol
    let associationUuid: F4SUUID
    var association: ExpandedAssociation?
    var view: HostViewController?
    var host: HostJson?
    
    init(coordinator: ApplicationsCoordinator,
         hostService: HostsProviderProtocol,
         locationService: AssociationsServiceProtocol,
         associationUuid: F4SUUID) {
        self.coordinator = coordinator
        self.hostService = hostService
        self.locationService = locationService
        self.associationUuid = associationUuid
    }
    
    func onViewDidLoad(view: HostViewController) {
        self.view = view
    }
    
    func onTapLinkedin() {
        coordinator.openUrl(host?.linkedinUrlString)
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        locationService.fetchAssociation(uuid: associationUuid) { [weak self] (result) in
            switch result {
            case .success(let association):
                self?.association = ExpandedAssociation(association: association)
                self?.hostService.fetchHost(uuid: association.hostUuid) { [weak self ] (hostResult) in
                    guard let self = self else { return }
                    switch hostResult {
                    case .success(let host):
                        self.host = host
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
}

fileprivate extension ExpandedAssociation {
    init(association: AssociationJson) {
        self.init()
        self.uuid = association.uuid
        self.title = association.title
        self.description = association.description
        self.isSelected = association.isSelected
        self.started = association.started
        self.stopped = association.stopped
    }
}

