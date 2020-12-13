
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
            case .success(let model): break
//                self?.hostService.fetchHost(uuid: model.host) { [weak self ] (hostResult) in
//                    guard let self = self else { return }
//                    switch hostResult {
//                    case .success(let host):
//                        self.host = host
//                        self.association = HostAssociationJson(uuidAssociation: model, host: host)
//                        completion(nil)
//                    case .failure(let error):
//                        completion(error)
//                    }
//                }
            case .failure(let error):
                completion(error)
            }
        }
    }
}
