
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI

protocol RecommendationTilePresenterProtocol {
    var companyName: String? { get }
    var companyImage: UIImage? { get }
    var hostName: String? { get }
    var hostRole: String? { get }
    var isProject: Bool { get }
    var projectHeader: String? { get }
    var projectTitle: String? { get }
    func onTileTapped()
}

class RecommendationTilePresenter: RecommendationTilePresenterProtocol {
    
    let row: Int
    weak var parentPresenter: RecommendationsPresenter?
    let recommendation: RecommendationsListItem
    var companyName: String? { recommendation.association?.location?.company?.name }
    var hostName: String? { recommendation.association?.host?.fullName }
    var hostRole: String? { recommendation.association?.title }

    var companyLogoUrlString: String? { recommendation.association?.location?.company?.logo }
    var downloadedImage: UIImage?
    var companyImage: UIImage? { downloadedImage ?? defaultImage }
    var imageService: SmallImageServiceProtocol = SmallImageService()
    var isProject: Bool { recommendation.project != nil }
    var projectHeader: String? { isProject ? "WORK PLACEMENT" : nil }
    var projectTitle: String?  { isProject ? recommendation.project?.name : nil }
    var projectUuid: F4SUUID? { recommendation.project?.uuid }
    
    var defaultImage: UIImage? {
        UIImage.imageWithFirstLetter(
            string: companyName,
            backgroundColor: WorkfinderColors.primaryColor,
            width: 70)
    }
    
    func loadImage() {
        let indexPath = IndexPath(row: self.row, section: 0)
        imageService.fetchImage(
            urlString: companyLogoUrlString,
            defaultImage: defaultImage) { [weak self] (image) in
                guard let self = self else { return }
                self.downloadedImage = image
                self.parentPresenter?.refreshRow(indexPath)
        }
    }
    
    func onTileTapped() {
        parentPresenter?.onTileTapped(self)
    }
    
    func onApplyTapped() {
        let projectInfo = ProjectInfoPresenter(item: recommendation)
        parentPresenter?.onApplyButtonTapped(projectInfo)
    }

    init(parent: RecommendationsPresenter,
         recommendation: RecommendationsListItem,
         workplaceService: ApplicationContextService?,
         projectService: ProjectServiceProtocol?,
         hostService: HostsProviderProtocol?,
         row: Int) {
        self.parentPresenter = parent
        self.recommendation = recommendation
        self.row = row
        loadImage()
    }
}

protocol ProjectPointer {
    var projectUuid: F4SUUID? { get }
}

extension RecommendationTilePresenter: ProjectPointer {}

extension RecommendationTilePresenter: OpportunityTilePresenterProtocol {
    var isRemote: Bool? {
        recommendation.project?.isRemote
    }
    
    var isPaid: Bool? {
        recommendation.project?.isPaid
    }
    
    var skills: [String] {
        recommendation.project?.skillsAcquired ?? []
    }
    
    var shouldHideSkills: Bool {
        false
    }
    
    var locationValue: String {
        (recommendation.project?.isRemote ?? false) ? "Remote" : "On-site"
    }
    
    var compensationValue: String {
        (recommendation.project?.isPaid ?? true) ? "Paid" : "Voluntary"
    }
    
}
