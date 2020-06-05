
import WorkfinderCommon

class HostViewPresenter {
    let coordinator: ApplicationsCoordinator
    let hostLocationService: HostLocationAssociationsServiceProtocol
    let hostService: HostsProviderProtocol
    let associationUuid: F4SUUID
    var association: HostLocationAssociationJson?
    var view: HostViewController?
    var host: Host?
    
    init(coordinator: ApplicationsCoordinator,
         hostService: HostsProviderProtocol,
         hostLocationService: HostLocationAssociationsServiceProtocol,
         associationUuid: F4SUUID) {
        self.coordinator = coordinator
        self.hostService = hostService
        self.hostLocationService = hostLocationService
        self.associationUuid = associationUuid
    }
    
    func onViewDidLoad(view: HostViewController) {
        self.view = view
    }
    
    func onTapLinkedin() {
        coordinator.openUrl(host?.linkedinUrlString)
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        hostLocationService.fetchAssociation(uuid: associationUuid) { [weak self] (result) in
            switch result {
            case .success(let model):
                self?.hostService.fetchHost(uuid: model.host) { [weak self ] (hostResult) in
                    guard let self = self else { return }
                    switch hostResult {
                    case .success(let host):
                        self.host = host
                        self.association = HostLocationAssociationJson(uuidAssociation: model, host: host)
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