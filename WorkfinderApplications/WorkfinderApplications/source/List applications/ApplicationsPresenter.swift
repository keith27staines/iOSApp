import Foundation
import WorkfinderUI
import WorkfinderCommon
import WorkfinderServices

class ApplicationsPresenter: NSObject {
    
    typealias DataSource = UITableViewDiffableDataSource<Section, ItemWrapper>
    typealias Snapshot =  NSDiffableDataSourceSnapshot<Section, ItemWrapper>
    
    weak var coordinator: ApplicationsCoordinatorProtocol?
    
    private var table: UITableView?
    
    let service: ApplicationsServiceProtocol
    weak var view: WorkfinderViewControllerProtocol?
    var isCandidateSignedIn: () -> Bool
    
    private var snapshot: Snapshot?
    
    enum Section: Int, CaseIterable {
        case upcomingInterviews
        case offersAndInterviews
        case applicationsHeader
        case applications
    }
    
    private var applications = [Application]()
    private var allInterviews = [InterviewJson]()
    private var offeredApplications = [Application]()
    
    private var datasource: DataSource?
    
    func updateSnapshot() {
        let animated = snapshot != nil
        let snapshot = makeSnapshot()
        datasource?.apply(snapshot, animatingDifferences: animated, completion: nil)
        self.snapshot = snapshot
    }
    
    func makeSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { section in
            var items = [ItemWrapper]()
            switch section {
            case .upcomingInterviews:
                items.append(ItemWrapper.interviewList(data: upcomingInterviewsData))
            case .offersAndInterviews:
                items.append(ItemWrapper.offerList(data: offersAndInterviewsData))
            case .applicationsHeader:
                items.append(ItemWrapper.heading(data: "Applications"))
            case .applications:
                items = applications.map({ application in
                    ItemWrapper.application(data: application)
                })
            }
            snapshot.appendItems(items, toSection: section)
        }
        return snapshot
    }
    
    private var offersAndInterviewsData: [[OfferTileData]] {
        let data = offeredApplicationData + offeredInterviewData
        return [data]
    }
    
    private var upcomingInterviewsData: [[InterviewInviteTileData]] {
        let upcomingInterviews = allInterviews.filter { interview in
            interview.status == "interview_accepted" || interview.status == "meeting_link_added"
        }
        let data = upcomingInterviews.map { interview -> InterviewInviteTileData in
            let tileData = InterviewInviteTileData(
                interview: interview,
                secondaryButtonAction: { [weak self] in
                    guard
                        let self = self,
                        let application = self.application(for: interview)
                    else { return }
                    self.performOnTapAction(application: application)
                },
                secondardyButtonText: "View Application"
            )
            return tileData
        }
        return [data]
    }
    
    private func application(for interview: InterviewJson) -> Application? {
        applications.first { application in
            application.placementUuid == interview.placement?.uuid
        }
    }
    
    private var offeredApplicationData: [OfferTileData] {
        offeredApplications.map { application in
            OfferTileData(application: application) { [weak self] offerData in
                guard let self = self else { return }
                self.coordinator?.performAction(.viewOffer(placementUuid: application.placementUuid), appSource: .applicationsTab)
            }
        }
    }
    
    private var offeredInterviewData: [OfferTileData] {
        allInterviews.filter({
            $0.status == "interview_offered"
        }).map { interview in
            OfferTileData(
                offerType: .interview(id: interview.id ?? -1),
                imageUrlString: interview.placement?.association?.host?.photo,
                defaultImageText: interview.placement?.association?.host?.fullname,
                buttonState: .normal,
                hostName: interview.placement?.association?.host?.fullname,
                companyName: interview.placement?.association?.location?.company?.name
            ) { [weak self] offerData in
                guard let self = self else { return }
                self.coordinator?.performAction(.viewInterview(interviewId: interview.id ?? -1), appSource: .applicationsTab)
            }
        }
    }
    
    private lazy var upcomingInterviewsTableViewCell: UITableViewCell = {
        let cell = UITableViewCell()
        let content = cell.contentView
        cell.contentView.addSubview(upcomingInterviewsCarousel)
        upcomingInterviewsCarousel.anchor(top: content.topAnchor, leading: content.leadingAnchor, bottom: content.bottomAnchor, trailing: content.trailingAnchor)
        return cell
    }()
    
    private lazy var upcomingInterviewsCarousel: CarouselView<InterviewInviteCell> = {
        let cellSize = CGSize(width: 255, height: 320)
        let carousel = CarouselView<InterviewInviteCell>(cellSize: cellSize, title: "Upcoming Interviews")
        carousel.registerCell(cellClass: InterviewInviteCell.self, withIdentifier: InterviewInviteCell.identifier)
        return carousel
    }()

    private lazy var offersAndInterviewsTableViewCell: UITableViewCell = {
        let cell = UITableViewCell()
        let content = cell.contentView
        cell.contentView.addSubview(offersAndInterviewsCarousel)
        offersAndInterviewsCarousel.anchor(top: content.topAnchor, leading: content.leadingAnchor, bottom: content.bottomAnchor, trailing: content.trailingAnchor)
        return cell
    }()

    private lazy var offersAndInterviewsCarousel: CarouselView<OfferCell> = {
        let cellSize = CGSize(width: 255, height: 200)
        let carousel = CarouselView<OfferCell>(cellSize: cellSize, title: "Offers and Interviews")
        carousel.registerCell(cellClass: OfferCell.self, withIdentifier: OfferCell.identifier)
        return carousel
    }()
    
    var showNoApplicationsYetMessage: Bool {
        isLoading == false && isDataShown == false
    }
    
    var isDataShown: Bool {
        applications.count > 0 || offersAndInterviewsData[0].count > 0 || upcomingInterviewsData[0].count > 0
    }
    
    init(coordinator: ApplicationsCoordinatorProtocol,
         service: ApplicationsService,
         isCandidateSignedIn: @escaping () -> Bool
    ) {
        self.service = service
        self.coordinator = coordinator
        self.isCandidateSignedIn = isCandidateSignedIn
    }
    
    func applicationForRow(_ row: Int) -> Application {
        return applications[row]
    }
    
    func onViewDidLoad(view: WorkfinderViewControllerProtocol, table: UITableView) {
        self.view = view
        self.table = table
        datasource = DataSource(tableView: table) { [weak self] tableView, indexPath, itemIdentifier in
            guard let self = self else { return UITableViewCell() }
            switch itemIdentifier {
            case .interviewList(let interviewData):
                if interviewData[0].count > 0 {
                    self.upcomingInterviewsCarousel.cellData = interviewData
                    return self.upcomingInterviewsTableViewCell
                } else {
                    return ZeroHeightTableViewCell()
                }
            case .offerList(let offersData):
                if offersData[0].count > 0 {
                    self.offersAndInterviewsCarousel.cellData = offersData
                    return self.offersAndInterviewsTableViewCell
                } else {
                    return ZeroHeightTableViewCell()
                }
            case .heading(let text):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TableSectionHeaderCell.reuseIdentifier) as? TableSectionHeaderCell else { return UITableViewCell() }
                cell.label.text = text
                return cell
            case .application(let applicationData):
                guard let tile = tableView.dequeueReusableCell(withIdentifier: ApplicationTile.reuseIdentifier) as? ApplicationTile
                else { return UITableViewCell() }
                let presenter = ApplicationTilePresenter(application: applicationData)
                tile.configureWithApplication(presenter)
                return tile
            }
        }
    }
    private var isLoading: Bool = false
    func loadData(completion: @escaping (Error?) -> Void) {
        isLoading = true
        guard isCandidateSignedIn() else {
            isLoading = false
            completion(nil)
            return
        }
        loadOfferedApplications { [weak self] optionalError in
            guard let self = self else { return }
            if let error = optionalError {
                completion(error)
            } else {
                self.loadInterviews { [weak self] optionalError in
                    guard let self = self else { return }
                    if let error = optionalError {
                        completion(error)
                    } else {
                        self.loadApplicationsList { [weak self] optionalError in
                            guard let self = self else { return }
                            self.isLoading = false
                            self.updateSnapshot()
                            completion(optionalError)
                        }
                    }
                }
            }
        }
    }
    
    func loadOfferedApplications(completion: @escaping (Error?) -> Void) {
        service.fetchAllApplications { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let serverlistJson):
                self.offeredApplications = serverlistJson.results.filter({ application in
                    application.state == .offered
                })
                completion(nil)
            case .failure(let error):
                completion(error)
                break
            }
        }
    }
    
    func loadInterviews(completion: @escaping (Error?) -> Void) {
        service.fetchInterviews { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let allInterviews):
                self.allInterviews = allInterviews
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func loadApplicationsList(completion: @escaping (Error?) -> Void) {
        self.service.fetchAllApplications { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let list):
                self.applications = list.results
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func onTapApplication(at row: Int) {
        let application = applicationForRow(row)
        performOnTapAction(application: application)
    }
    
    func performOnTapAction(application: Application) {
        let action: ApplicationAction
        switch application.state {
        case .pending: action = .viewApplication(placementUuid: application.placementUuid)
        case .contacting: action = .viewApplication(placementUuid: application.placementUuid)
        case .viewed: action = .viewApplication(placementUuid: application.placementUuid)
        case .saved: action = .viewApplication(placementUuid: application.placementUuid)
        case .declined: action = .viewApplication(placementUuid: application.placementUuid)
        case .offered: action = .viewOffer(placementUuid: application.placementUuid)
        case .accepted: action = .viewOffer(placementUuid: application.placementUuid)
        case .withdrawn: action = .viewOffer(placementUuid: application.placementUuid)
        case .expired: action = .viewApplication(placementUuid: application.placementUuid)
        case .cancelled: action = .viewOffer(placementUuid: application.placementUuid)
        case .unknown: action = .viewApplication(placementUuid: application.placementUuid)
        case .interviewOffered:  action = .viewApplication(placementUuid: application.placementUuid)
        case .interviewConfirmed: action = .viewApplication(placementUuid: application.placementUuid)
        case .interviewMeetingLinkAdded: action = .viewApplication(placementUuid: application.placementUuid)
        case .interviewCompleted: action = .viewApplication(placementUuid: application.placementUuid)
        case .interviewDeclined: action = .viewApplication(placementUuid: application.placementUuid)
        case .unroutable: action = .viewApplication(placementUuid: application.placementUuid)
        }
        coordinator?.performAction(action, appSource: .applicationsTab)
    }
    
    func interviewForPlacement(placementUuid: F4SUUID) -> F4SUUID? {
        allInterviews.first { interview in
            interview.placement?.uuid == placementUuid
        }?.uuid
    }
}

class TableSectionHeaderCell: UITableViewCell {
    
    static var reuseIdentifier: String = "TableSectionHeaderCell"
    
    lazy var label: UILabel = {
        let label = UILabel()
        contentView.addSubview(label)
        let style = WFTextStyle.sectionTitle
        label.applyStyle(style)
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
        return label
    }()
}

class ZeroHeightTableViewCell: UITableViewCell {
    init() {
        super.init(style: .default, reuseIdentifier: "zeroHeightCell")
        let content = UIView()
        content.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentView.addSubview(content)
        content.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum ItemWrapper: Hashable {
    case offerList(data: [[OfferTileData]])
    case interviewList(data: [[InterviewInviteTileData]])
    case application(data: Application)
    case heading(data: String)
}
