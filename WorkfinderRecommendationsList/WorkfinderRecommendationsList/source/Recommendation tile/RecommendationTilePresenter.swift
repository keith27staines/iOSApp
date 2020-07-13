
import WorkfinderCommon
import WorkfinderServices

protocol RecommendationTilePresenterProtocol {
    var companyName: String? { get }
    var companyLogo: String? { get }
    var hostName: String? { get }
    var hostRole: String? { get }
    var isLoading: Bool { get }
    func onTileTapped()
    func loadData()
}

class RecommendationTilePresenter: RecommendationTilePresenterProtocol {
    
    let row: Int
    weak var parentPresenter: RecommendationsPresenter?
    let recommendation: Recommendation
    let workplaceService: WorkplaceAndAssociationService?
    var associationJson: AssociationJson?
    let hostService: HostsProviderProtocol?
    var companyName: String? { workplace?.companyJson.name }
    var industry: String? { company?.industries?.first?.name }
    var hostName: String? { host?.displayName }
    var hostRole: String? { association?.title }
    var workplace: Workplace?
    var company: CompanyJson? { workplace?.companyJson }
    var host: Host?
    var association: AssociationJson?
    var companyLogo: String? { company?.logo }
    var companyImage: UIImage?
    
    var isLoaded: Bool {
        workplace != nil && host != nil
    }
    
    var isLoading: Bool = false {
        didSet { if !isLoading { onDataLoadFinished() } }
    }
    
    func loadData() {
        guard let uuid = recommendation.uuid else { return }
        guard isLoading == false else { return }
        guard isLoaded == false else {
            onDataLoadFinished()
            return
        }
        isLoading = true

        guard workplace == nil || association == nil else {
            onCompanyAndAssociationLoaded(workplace: workplace, association: associationJson)
            return
        }
        workplaceService?.fetchCompanyWorkplace(recommendationUuid: uuid, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success((let workplace, _)):
                let association = self.workplaceService?.associationJson
                self.onCompanyAndAssociationLoaded(workplace: workplace, association: association)
            case .failure(let error):
                guard let error = error as? WorkfinderError, error.retry == true else {
                    self.isLoading = false
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                    self.loadData()
                }
            }
        })
    }
    
    func onCompanyAndAssociationLoaded(workplace: Workplace?, association: AssociationJson?) {
        self.workplace = workplace
        self.association = association
        if let host = host {
            onHostLoaded(host: host)
            return
        }
        guard let hostUuid = association?.host else { return }
        hostService?.fetchHost(uuid: hostUuid, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let host):
                self.onHostLoaded(host: host)
            case .failure(let error):
                guard let error = error as? WorkfinderError else { return }
                guard error.retry == true else {
                    self.isLoading = false
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                    self.onCompanyAndAssociationLoaded(workplace: workplace, association: association)
                }
            }
        })
    }
    
    func onHostLoaded(host: Host?) {
        self.host = host
        isLoading = false
    }
    
    func onDataLoadFinished() {
        parentPresenter?.refreshRow(row)
    }
    
    func onTileTapped() {
        parentPresenter?.onTileTapped(self)
    }

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
