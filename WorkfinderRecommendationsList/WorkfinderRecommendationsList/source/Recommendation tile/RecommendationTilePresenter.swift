
import WorkfinderCommon
import WorkfinderServices

class RecommendationTilePresenter {
    
    weak var parentPresenter: RecommendationsPresenter?
    let recommendation: Recommendation
    let workplaceService: WorkplaceAndAssociationService?
    let hostService: HostsProviderProtocol?
    var view: RecommendationTileView?
    var companyName: String? { didSet { view?.companyNameLabel.text = companyName } }
    var industry: String? { didSet { view?.industryLabel.text = industry } }
    var hostName: String? { didSet { view?.hostNameLabel.text = hostName } }
    var hostRole: String? { didSet { view?.hostRoleLabel.text = hostRole } }
    var workplace: Workplace?
    var host: Host?
    var association: AssociationJson?
    
    var companyLogo: String? {
        didSet {
            view?.companyLogo.load(companyName: self.companyName ?? "?", urlString: companyLogo, completion: nil)
        }
    }
    
    var hostPhoto: String? {
        didSet {
            view?.hostPhoto.load(hostName: self.hostName ?? "?", urlString: hostPhoto, completion: nil)
        }
    }
    
    func loadData() {
        guard let uuid = recommendation.uuid else { return }
        guard workplace == nil else {
            updateCompanyAndAssociationData()
            onAssociationLoaded(workplaceService?.associationJson)
            return
        }
        workplaceService?.fetchCompanyWorkplace(recommendationUuid: uuid, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success((let workplace, _)):
                self.workplace = workplace
                self.updateCompanyAndAssociationData()
                self.onAssociationLoaded(self.workplaceService?.associationJson)
            case .failure(_):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                    self.loadData()
                }
            }
        })
    }
    
    func onAssociationLoaded(_ association: AssociationJson?) {
        guard host == nil else {
            updateHostData()
            return
        }
        guard let hostUuid = association?.host else { return }
        hostService?.fetchHost(uuid: hostUuid, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let host):
                self.host = host
                self.updateHostData()
            case .failure(_):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                    self.onAssociationLoaded(association)
                }
            }
        })
    }
    
    private func updateCompanyAndAssociationData() {
        let company = workplace?.companyJson
        companyName = company?.name
        industry = company?.industries?.first?.name
        companyLogo = company?.logo
    }
    
    private func updateHostData() {
        hostName = host?.displayName
        hostRole = self.workplaceService?.associationJson?.title
        hostPhoto = host?.photoUrlString
    }
    
    func onTileTapped() {
        parentPresenter?.onTileTapped(self)
    }

    init(parent: RecommendationsPresenter,
         recommendation: Recommendation,
         workplaceService: WorkplaceAndAssociationService?,
         hostService: HostsProviderProtocol?) {
        self.parentPresenter = parent
        self.recommendation = recommendation
        self.workplaceService = workplaceService
        self.hostService = hostService
    }
}
