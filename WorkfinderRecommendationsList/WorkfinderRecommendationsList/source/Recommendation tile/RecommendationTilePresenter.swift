
import WorkfinderCommon
import WorkfinderServices

protocol RecommendationTilePresenterProtocol {
    var view: RecommendationTileViewProtocol? { get set }
    var companyName: String? { get }
    var hostName: String? { get }
    var hostRole: String? { get }
    func onTileTapped()
    func loadData()
}

class RecommendationTilePresenter: RecommendationTilePresenterProtocol {
    
    weak var parentPresenter: RecommendationsPresenter?
    let recommendation: Recommendation
    let workplaceService: WorkplaceAndAssociationService?
    let hostService: HostsProviderProtocol?
    var companyName: String?
    var industry: String?
    var hostName: String?
    var hostRole: String?
    var workplace: Workplace?
    var host: Host?
    var association: AssociationJson?
    var companyLogo: String?
    
    var view: RecommendationTileViewProtocol?
    
    var isLoaded: Bool = false
    var isLoading: Bool = false
    
    func loadData() {
        view?.refreshFromPresenter(presenter: self)
        guard isLoading == false else { return }
        isLoading = true
        guard isLoaded == false else { return }
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
            case .failure(let error):
                guard let error = error as? WorkfinderError, error.retry == true else { return }
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
                self.isLoaded = true
            case .failure(let error):
                guard let error = error as? WorkfinderError else { return }
                guard error.retry == true else {
                    return
                }
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
        parentPresenter?.refreshRow(row)
        //self.view?.refreshFromPresenter(presenter: self)
    }
    
    private func updateHostData() {
        hostName = host?.displayName
        hostRole = self.workplaceService?.associationJson?.title
        parentPresenter?.refreshRow(row)
    }
    
    func onTileTapped() {
        parentPresenter?.onTileTapped(self)
    }
    
    let row: Int

    init(parent: RecommendationsPresenter,
         recommendation: Recommendation,
         workplaceService: WorkplaceAndAssociationService?,
         hostService: HostsProviderProtocol?,
         row: Int) {
        self.parentPresenter = parent
        self.recommendation = recommendation
        self.workplaceService = workplaceService
        self.hostService = hostService
        self.row = row
    }
}
