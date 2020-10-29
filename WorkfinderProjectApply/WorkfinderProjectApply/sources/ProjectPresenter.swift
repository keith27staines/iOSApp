
import Foundation
import WorkfinderCommon
import WorkfinderServices

protocol ProjectPresenterProtocol {
    var companyName: String? { get }
    var companyLogoUrl: String? { get }
    var projectName: String? { get }
    var status: String? {get }
    var isOpenForApplication: Bool { get }
    func loadData(completion: @escaping (Error?) -> Void)
    func onViewDidLoad(view: ProjectViewProtocol)
    func numberOfSections() -> Int
    func numberOfItemsInSection(_ section: Int) -> Int
    func presenterForIndexPath(_ indexPath: IndexPath) -> CellPresenterProtocol?
    func reuseIdentifierForSection(_ section: Int) -> String?
    func reuseIdentifierForSection(_ section: ProjectPresenter.Section) -> String
}

class ProjectPresenter: ProjectPresenterProtocol {

    enum Section: Int, CaseIterable {
        case projectHeader
        case projectBulletPoints
        case aboutCompanySectionHeading
        case aboutCompany
        case aboutPlacementSectionHeading
        case aboutPlacement
        case additionalCommentsHeading
        case additionalComments
        case skillsHeading
        case skillsYouWillGain
        case keyActivitiesSectionHeading
        case keyActivities
        case aboutYouSectionHeading
        case aboutYou
        case projectContactSectionheading
        case projectContact
        
        var reuseIdentifer: String {
            let aboutIdentifier = "about"
            let sectionHeadingIdentifier = "sectionHeading"
            switch self {
            case .projectHeader: return "projectTitle"
            case .projectBulletPoints: return "projectBulletPoints"
            case .aboutCompanySectionHeading: return sectionHeadingIdentifier
            case .aboutCompany: return aboutIdentifier
            case .aboutPlacementSectionHeading: return sectionHeadingIdentifier
            case .aboutPlacement: return aboutIdentifier
            case .additionalCommentsHeading: return sectionHeadingIdentifier
            case .additionalComments: return aboutIdentifier
            case .skillsHeading: return sectionHeadingIdentifier
            case .skillsYouWillGain: return "capsule"
            case .keyActivitiesSectionHeading: return sectionHeadingIdentifier
            case .keyActivities: return "keyActivities"
            case .aboutYouSectionHeading: return sectionHeadingIdentifier
            case .aboutYou: return aboutIdentifier
            case .projectContactSectionheading: return sectionHeadingIdentifier
            case .projectContact: return "projectContact"
            }
        }
    }
    
    weak var coordinator: ProjectApplyCoordinator?
    weak var view: ProjectViewProtocol?
    let projectUuid: F4SUUID
    let service: ProjectAndAssociationDetailsServiceProtocol
    
    var detail: ProjectAndAssociationDetail = ProjectAndAssociationDetail() {
        didSet { view?.refreshFromPresenter() }
    }
    
    private var company: CompanyJson? { detail.associationDetail?.company }
    private var association: AssociationDetail? { detail.associationDetail }
    private var host: Host? { detail.associationDetail?.host }
    private var projectType: String? { detail.projectType }
    private var project: ProjectJson? { detail.project }
    var projectName: String? { project?.name }
    var companyName: String? { company?.name }
    var companyLogoUrl: String? { company?.logo }
    var additionalRequirements: String? { detail.project?.additionalComments }
    var skills: [String] { project?.skillsAcquired ?? [] }
    private var activities: [String] { project?.candidateActivities ?? [] }
    
    var isOpenForApplication: Bool {
        detail.project?.status == "open" ? true : false
    }
    
    var status: String? {
        detail.project?.status
    }
    
    init(coordinator: ProjectApplyCoordinator,
         projectUuid: F4SUUID,
         projectService: ProjectAndAssociationDetailsServiceProtocol) {
        self.coordinator = coordinator
        self.projectUuid = projectUuid
        self.service = projectService
    }
    
    func onViewDidLoad(view: ProjectViewProtocol) {
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        service.fetch(projectUuid: projectUuid) { (result) in
            switch result {
            case .success(let detail):
                self.detail = detail
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func reuseIdentifierForSection(_ section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        return reuseIdentifierForSection(section)
    }
    
    func reuseIdentifierForSection(_ section: Section) -> String {
        return section.reuseIdentifer
    }
    
    func numberOfSections() -> Int  { Section.allCases.count }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .projectHeader: return 1
        case .projectBulletPoints: return 4
        case .aboutCompanySectionHeading: return 1
        case .aboutCompany: return 1
        case .aboutPlacementSectionHeading: return 1
        case .aboutPlacement: return 1
        case .additionalCommentsHeading: return 1
        case .additionalComments: return 1
        case .skillsHeading: return 1
        case .skillsYouWillGain: return 1
        case .keyActivitiesSectionHeading: return 1
        case .keyActivities: return activities.count
        case .aboutYouSectionHeading: return 1
        case .aboutYou:  return 1
        case .projectContactSectionheading: return 1
        case .projectContact: return 1
        }
    }
    
    func presenterForIndexPath(_ indexPath: IndexPath) -> CellPresenterProtocol? {
        guard let section = Section(rawValue: indexPath.section) else { return nil }
        switch section {
        case .projectHeader:
            return ProjectHeaderPresenter(
                companyName: companyName,
                projectName: projectName ?? ""
            )
        case .projectBulletPoints:
            var locationString: String = "n/a"
            switch indexPath.row {
            case 0:
                if detail.project?.isRemote == true {
                    locationString = "This is a remote project"
                } else {
                    if let city = detail.associationDetail?.location?.address_city {
                        locationString = "The company is based in \(city)"
                    }
                }
                return ProjectBulletPointsPresenter(
                title: "Location",
                text: locationString)
            case 1:
                let isPaid = detail.project?.isPaid ?? false
                let text = isPaid ? "This is a paid work placement at £6.45-8.21 p/h depending on age" : "This is a voluntary project."
                return ProjectBulletPointsPresenter(
                    title: "Salary",
                    text: text)
            case 2:
                let defaultText = "2 weeks"
                var text = detail.project?.duration ?? defaultText
                if text.isEmpty { text = defaultText }
                return ProjectBulletPointsPresenter(
                    title: "Duration",
                    text: text)
            case 3:
                guard
                    let workfinderDateString = detail.project?.startDate,
                    let date = Date.workfinderDateStringToDate(workfinderDateString)
                else {
                    return ProjectBulletPointsPresenter(title: "Start date", text: "unspecified")
                }
                return ProjectBulletPointsPresenter(title: "Start date", text: date.workfinderDateString)
            default:
                return nil
            }
        case .aboutCompanySectionHeading:
            return SectionHeadingPresenter(title: "About \(companyName ?? "Company")")
        case .aboutCompany:
            return AboutPresenter(text: company?.description, defaultText: "No description available")
        case .aboutPlacementSectionHeading:
            return SectionHeadingPresenter(title: "About \(projectName ?? "Project")")
        case .aboutPlacement:
            return AboutPresenter(text: project?.description, defaultText: "No description available")
        case .additionalCommentsHeading:
            return SectionHeadingPresenter(title: "Additional requirements")
        case .additionalComments:
            return AboutPresenter(text: additionalRequirements, defaultText: "There are no additional requirements.")
        case .skillsHeading:
            return SectionHeadingPresenter(title: "Skills you will gain")
        case .skillsYouWillGain:
            return CapsuleCollectionPresenter(strings: skills)
        case .keyActivitiesSectionHeading:
            return SectionHeadingPresenter(title: "Key activities")
        case .keyActivities:
            return KeyActivityPresenter(activity: activities[indexPath.row])
        case .aboutYouSectionHeading:
            return SectionHeadingPresenter(title: "About you")
        case .aboutYou:
            return AboutPresenter(text: detail.project?.aboutCandidate, defaultText: "No candidate qualities are specifed")
        case .projectContactSectionheading:
            return SectionHeadingPresenter(title: "Project contact")
        case .projectContact:
            return ProjectContactPresenter(host: host, role: association?.title)
        }
    }
}
