
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI

protocol OpportunityTilePresenterProtocol {
    var companyName: String? { get }
    var companyImage: UIImage? { get }
    var isProject: Bool { get }
    var projectHeader: String? { get }
    var projectTitle: String? { get }
    var shouldHideSkills: Bool { get }
    var locationValue: String { get }
    var compensationValue: String { get }
    var isRemote: Bool? { get }
    var isPaid: Bool? { get }
    var skills: [String] { get }
    var skillsText: String { get}
    var skillsAttributedString: NSAttributedString { get }
    func onTileTapped()
    func onApplyTapped()
}

extension OpportunityTilePresenterProtocol {
    var locationValue: String { isRemote ?? false ? "Remote" : "On-site" }
    var compensationValue: String { isPaid ?? true ? "Paid" : "Voluntary" }
    var shouldHideSkills: Bool { skillsText.count == 0 }
    var skillsText: String {
        var skillsList = skills.prefix(3).reduce("", { result, skill in
            let result = result ?? ""
            let bulletPointWithSkill = " •  \(skill)"
            return result.count == 0 ? bulletPointWithSkill : result + "\n\(bulletPointWithSkill)"
        }) ?? ""
        if skills.count > 3 {
           skillsList += ", and more"
        }
        return skillsList
    }
    
    var skillsAttributedString: NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.16
        return NSMutableAttributedString(string: "\(skillsText)", attributes: [NSAttributedString.Key.kern: -0.08, NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
}

class OpportunityTilePresenter: OpportunityTilePresenterProtocol {
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
    
    var skills: [String] { project.skillsAcquired ?? [] }
        
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
    
    func onApplyTapped() {
        parentPresenter?.onApplyButtonTapped(self)
    }
    
    var isRemote: Bool? { project.isRemote }
    var isPaid: Bool? { project.isPaid }

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
