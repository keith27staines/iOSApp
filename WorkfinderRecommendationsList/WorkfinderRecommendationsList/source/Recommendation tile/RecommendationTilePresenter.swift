
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI

protocol RecommendationTilePresenterProtocol {
    var view: RecommendationTileViewProtocol? { get set }
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
    
    weak var view: RecommendationTileViewProtocol?
    let row: Int
    weak var parentPresenter: RecommendationsPresenter?
    let recommendation: RecommendationsListItem
    var companyName: String? { recommendation.association?.location?.company?.name }
    var hostName: String? { recommendation.association?.host?.fullName }
    var hostRole: String? { recommendation.association?.title }

    var defaultImage: UIImage? {
        UIImage.imageWithFirstLetter(
            string: companyName,
            backgroundColor: WorkfinderColors.primaryColor,
            width: 70)
    }
    var companyLogoUrlString: String? { recommendation.association?.location?.company?.logo }
    var downloadedImage: UIImage?
    var companyImage: UIImage? { downloadedImage ?? defaultImage }
    var imageService: SmallImageServiceProtocol = SmallImageService()
    var isProject: Bool { recommendation.project != nil }
    var projectHeader: String? { isProject ? "WORK PLACEMENT" : nil }
    var projectTitle: String?  { isProject ? recommendation.project?.name : nil }
    
    func loadImage() {
        imageService.fetchImage(
            urlString: companyLogoUrlString,
            defaultImage: defaultImage) { [weak self] (image) in
                guard let self = self else { return }
                self.downloadedImage = image
                self.parentPresenter?.refreshRow(self.row)
        }
    }
    
    func onTileTapped() {
        parentPresenter?.onTileTapped(self)
    }

    init(parent: RecommendationsPresenter,
         recommendation: RecommendationsListItem,
         workplaceService: WorkplaceAndAssociationService?,
         projectService: ProjectServiceProtocol?,
         hostService: HostsProviderProtocol?,
         row: Int) {
        self.parentPresenter = parent
        self.recommendation = recommendation
        self.row = row
        loadImage()
    }
}
