
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI

protocol OpportunityTilePresenterProtocol {
    var view: RecommendationTileViewProtocol? { get set }
    var companyName: String? { get }
    var companyImage: UIImage? { get }
    var isProject: Bool { get }
    var projectHeader: String? { get }
    var projectTitle: String? { get }
    var skills: String? { get }
    func onTileTapped()
}

class OpportunityTilePresenter: OpportunityTilePresenterProtocol {
    weak var view: RecommendationTileViewProtocol?
    let row: Int
    weak var parentPresenter: RecommendationsPresenter?
    let project: ProjectJson
    var companyName: String? { project.association?.location?.company?.name }

    var companyLogoUrlString: String? { project.association?.location?.company?.logo }
    var downloadedImage: UIImage?
    var companyImage: UIImage? { downloadedImage ?? defaultImage }
    var imageService: SmallImageServiceProtocol = SmallImageService()
    var isProject = true
    var projectHeader: String? { isProject ? "WORK PLACEMENT" : nil }
    var projectTitle: String?  { project.name }
    var skills: String? {
        var skillsList = project.skillsAcquired?.prefix(3).reduce("", { result, skill in
            result + "\n* \(skill)"
        }) ?? ""
        if project.skillsAcquired?.count ?? 0 > 3 {
           skillsList += ", and more"
        }
        return skillsList
    }
    
    var defaultImage: UIImage? {
        UIImage.imageWithFirstLetter(
            string: companyName,
            backgroundColor: WorkfinderColors.primaryColor,
            width: 70)
    }
    
    func loadImage() {
        let indexPath = IndexPath(row: self.row, section: 1)
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

    init(parent: RecommendationsPresenter,
         project: ProjectJson,
         workplaceService: ApplicationContextService?,
         projectService: ProjectServiceProtocol?,
         hostService: HostsProviderProtocol?,
         row: Int) {
        self.parentPresenter = parent
        self.project = project
        self.row = row
        loadImage()
    }
}

extension OpportunityTilePresenter: ProjectPointer {
    var projectUuid: F4SUUID? {
        project.uuid
    }
}
