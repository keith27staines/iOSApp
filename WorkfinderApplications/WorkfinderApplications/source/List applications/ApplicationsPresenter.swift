import Foundation
import WorkfinderUI
import WorkfinderCommon
import WorkfinderServices



class ApplicationsPresenter: NSObject {
    weak var coordinator: ApplicationsCoordinatorProtocol?
    private var table: UITableView?
    
    let service: ApplicationsServiceProtocol
    weak var view: WorkfinderViewControllerProtocol?
    var isCandidateSignedIn: () -> Bool
    
    enum Section: Int, CaseIterable {
        case upcomingInterviews
        case offersAndInterviews
        case applicationsHeader
        case applications
    }
    
    private var applications = [Application]()
    private var allInterviews = [InterviewJson]()
    private var offeredApplications = [Application]()
    
    private var offersAndInterviewsData: [[OfferData]] {
        let data = offeredApplicationData + offeredInterviewData
        return [data]
    }
    
    private var upcomingInterviewsData: [[InterviewInviteData]] {
        let upcomingInterviews = allInterviews.filter { interview in
            interview.status == "interview_accepted" || interview.status == "interview_meeting_link_added"
        }
        let data = upcomingInterviews.map { interview in InterviewInviteData(interview: interview) }
        return [data]
    }
    
    private var offeredApplicationData: [OfferData] {
        offeredApplications.map { application in
            OfferData(
                offerType: .placement(uuid: application.placementUuid),
                imageUrlString: application.logoUrl,
                defaultImageText: application.companyName,
                buttonState: .normal,
                hostName: application.hostName,
                companyName: application.companyName
            ) { [weak self] offerData in
                guard let self = self else { return }
                self.coordinator?.performAction(.viewOffer(placementUuid: application.placementUuid), appSource: .applicationsTab)
            }
        }
    }
    
    private var offeredInterviewData: [OfferData] {
        allInterviews.filter({
            $0.status == "open"
        }).map { interview in
            OfferData(
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
        let cellSize = CGSize(width: 255, height: 291)
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

    private var offersAndInterviewsCarousel: CarouselView<OfferCell> = {
        let cellSize = CGSize(width: 255, height: 186)
        let carousel = CarouselView<OfferCell>(cellSize: cellSize, title: "Offers and Interviews")
        carousel.registerCell(cellClass: OfferCell.self, withIdentifier: OfferCell.identifier)
        return carousel
    }()
    
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
    
    func onViewDidLoad(view: WorkfinderViewControllerProtocol) {
        self.view = view
    }
    
    func loadData(table: UITableView, completion: @escaping (Error?) -> Void) {
        table.dataSource = self
        self.table = table
        table.reloadData()
        guard isCandidateSignedIn() else {
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
                            self.reloadViews()
                            completion(optionalError)
                        }
                    }
                }
            }
        }
    }
    
    func reloadViews() {
        table?.reloadData()
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
}

extension ApplicationsPresenter: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .upcomingInterviews:
            return upcomingInterviewsData.count
        case .offersAndInterviews:
            return offeredInterviewData.count
        case .applicationsHeader:
            return 1
        case .applications:
            return applications.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .upcomingInterviews:
            if upcomingInterviewsData[0].count > 0 {
                upcomingInterviewsCarousel.cellData = upcomingInterviewsData
                return upcomingInterviewsTableViewCell
            } else {
                return ZeroHeightTableViewCell()
            }
        case .offersAndInterviews:
            offersAndInterviewsCarousel.cellData = offersAndInterviewsData
            return offersAndInterviewsTableViewCell
        case .applicationsHeader:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TableSectionHeaderCell.reuseIdentifier) as? TableSectionHeaderCell else { return UITableViewCell() }
            cell.label.text = "Applications"
            return cell
        case .applications:
            guard let tile = tableView.dequeueReusableCell(withIdentifier: ApplicationTile.reuseIdentifier) as? ApplicationTile
            else { return UITableViewCell() }
            let application = applications[indexPath.row]
            let presenter = ApplicationTilePresenter(application: application)
            tile.configureWithApplication(presenter)
            return tile
        }
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
