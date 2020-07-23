
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI

protocol RecommendationTilePresenterProtocol {
    var view: RecommendationTileViewProtocol? { get set }
    var companyName: String? { get }
    var companyImage: UIImage? { get }
    var hostName: String? { get }
    var hostRole: String? { get }
    var isLoading: Bool { get }
    var isProject: Bool { get }
    var projectHeader: String? { get }
    var projectTitle: String? { get }
    func onTileTapped()
    func loadData()
}

class RecommendationTilePresenter: RecommendationTilePresenterProtocol {
    weak var view: RecommendationTileViewProtocol?
    let row: Int
    weak var parentPresenter: RecommendationsPresenter?
    let recommendation: Recommendation
    let workplaceService: WorkplaceAndAssociationService?
    let projectService: ProjectServiceProtocol?
    var associationJson: AssociationJson?
    let hostService: HostsProviderProtocol?
    var companyName: String? { workplace?.companyJson.name }
    var industry: String? { company?.industries?.first?.name }
    var hostName: String? { host?.displayName }
    var hostRole: String? { association?.title }
    var workplace: Workplace?
    var company: CompanyJson? { workplace?.companyJson }
    var host: Host?
    var projectType: ProjectTypeJson?
    var association: AssociationJson?
    var defaultImage: UIImage? {
        UIImage.imageWithFirstLetter(
            string: companyName,
            backgroundColor: WorkfinderColors.primaryColor,
            width: 70)
    }
    var companyLogo: String? {
        didSet {
            imageService.fetchImage(
                urlString: companyLogo,
                defaultImage: defaultImage) { [weak self] (image) in
                    guard let self = self else { return }
                    self.downloadedImage = image
                    self.onDataLoadFinished()
            }
        }
    }
    var downloadedImage: UIImage?
    var companyImage: UIImage? { downloadedImage ?? defaultImage }
    var imageService: SmallImageServiceProtocol = SmallImageService()
    
    var isLoaded: Bool {
        workplace != nil && host != nil
    }
    
    var isProject: Bool { recommendation.project != nil }
    var projectHeader: String? { isProject ? "WORK PLACEMENT" : nil }
    var projectTitle: String?  { isProject ? projectType?.name : nil }
    
    var isLoading: Bool = false {
        didSet { if !isLoading { onDataLoadFinished() } }
    }
    
    func loadData() {
        guard let uuid = recommendation.uuid else { return }
        guard isLoading == false else { return }
        guard isLoaded == false else {
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
        loadProjectTypeIfNecessary()
    }
    
    func loadProjectTypeIfNecessary() {
        guard let projectTypeUuid = recommendation.project?.type else {
            isLoading = false
            return
        }
        projectService?.fetchProjectType(uuid: projectTypeUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let projectType):
                self.onProjectTypeLoaded(projectType: projectType)
            case .failure(let error):
                guard let error = error as? WorkfinderError else { return }
                guard error.retry == true else {
                    self.isLoading = false
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                    self.loadProjectTypeIfNecessary()
                }
            }
        }
    }
    
    func onProjectTypeLoaded(projectType: ProjectTypeJson) {
        self.projectType = projectType
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
         projectService: ProjectServiceProtocol?,
         hostService: HostsProviderProtocol?,
         row: Int) {
        self.parentPresenter = parent
        self.recommendation = recommendation
        self.workplaceService = workplaceService
        self.projectService = projectService
        self.hostService = hostService
        self.row = row
    }
}
