
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI

protocol ProjectPointer {
    var projectUuid: F4SUUID? { get }
}

struct OpportunityTileData: ProjectPointer, Hashable {
    
    weak var parentPresenter: RecommendationsPresenter?
    private let project: ProjectJson?
    private let recommendation: RecommendationsListItem?
    var companyName: String?
    var projectUuid: F4SUUID?
    var companyLogoUrlString: String?
    var downloadedImage: UIImage?
    var companyImage: UIImage? { downloadedImage ?? defaultImage }
    var imageService: SmallImageServiceProtocol = SmallImageService()
    var isProject = true
    var projectHeader: String? { isProject ? "WORK PLACEMENT" : nil }
    var projectTitle: String?
    
    var skills: [String]
    var town: String
    var locationValue: String {
        switch isRemote ?? false {
        case true: return "Remote"
        case false: return town.isEmpty ? "On-site" : town
        }
    }
    var defaultImage: UIImage? {
        UIImage.imageWithFirstLetter(
            string: companyName,
            backgroundColor: WorkfinderColors.primaryColor,
            width: 70)
    }

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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(recommendation)
        hasher.combine(project)
    }
    
    static func == (lhs: OpportunityTileData, rhs: OpportunityTileData) -> Bool {
        return lhs.recommendation == rhs.recommendation && lhs.project == rhs.project
    }
    
    func onTileTapped() {
        parentPresenter?.onTileTapped(self)
    }
    
    func onApplyTapped() {
        if let project = project {
            let projectInfo = ProjectInfoPresenter(projectJson: project)
            parentPresenter?.onApplyButtonTapped(projectInfo)
        }
        if let recommendation = recommendation {
            let projectInfo = ProjectInfoPresenter(recommendationListItem: recommendation)
            parentPresenter?.onApplyButtonTapped(projectInfo)
        }
    }
    
    var isRemote: Bool?
    var isPaid: Bool?

    init(parent: RecommendationsPresenter,
         project: ProjectJson
    ) {
        self.parentPresenter = parent
        self.project = project
        self.recommendation = nil
        self.isPaid = project.isPaid
        self.isRemote = project.isRemote
        self.skills = project.skillsAcquired ?? []
        self.projectTitle = project.name
        self.companyLogoUrlString = project.association?.location?.company?.logo
        self.town = (project.association?.location?.addressCity ?? "").capitalized
        self.companyName = project.association?.location?.company?.name
        self.projectUuid = project.uuid
    }
    
    init(parent: RecommendationsPresenter,
         recommendation: RecommendationsListItem
    ) {
        self.parentPresenter = parent
        self.project = nil
        self.recommendation = recommendation
        let project = recommendation.project
        self.isPaid = project?.isPaid
        self.isRemote = project?.isRemote
        self.skills = project?.skillsAcquired ?? []
        self.projectTitle = project?.name
        self.companyLogoUrlString = project?.association?.location?.company?.logo
        self.town = (project?.association?.location?.addressCity ?? "").capitalized
        self.companyName = project?.association?.location?.company?.name
        self.projectUuid = project?.uuid
    }
}
