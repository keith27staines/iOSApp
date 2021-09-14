import Foundation
import WorkfinderUI
import WorkfinderCommon
import WorkfinderServices



class ApplicationsPresenter: NSObject {
    weak var coordinator: ApplicationsCoordinatorProtocol?
    private var table: UITableView?
    
    var numberOfSections: Int { Section.allCases.count }
    let service: ApplicationsServiceProtocol
    weak var view: WorkfinderViewControllerProtocol?
    var isCandidateSignedIn: () -> Bool
    
    enum Section: Int, CaseIterable {
        case upcomingInterviews
        case offersAndInterviews
        case applications
    }

    var allInterviews = [InterviewJson]()
    
    private var offeredInterviews = [InterviewJson]()
    private var upcomingInterviews = [InterviewJson]()
    private var offeredApplications = [Application]()
    
    private var offersAndInterviews: [[OfferData]] {
        let data = _offeredApplicationData + _offeredInterviewData
        return [data]
    }
    
    private var _offeredApplicationData: [OfferData] {
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
                
            }
        }
    }
    
    private var _offeredInterviewData: [OfferData] {
        offeredInterviews.map { interview in
            OfferData(
                offerType: .interview(id: interview.id ?? -1),
                imageUrlString: interview.placement?.association?.host?.photo,
                defaultImageText: interview.placement?.association?.host?.fullname,
                buttonState: .normal,
                hostName: interview.placement?.association?.host?.fullname,
                companyName: interview.placement?.association?.location?.company?.name
            ) { [weak self] offerData in
                guard let self = self else { return }
            }
        }
    }

    private var applications = [Application]() {
        didSet {
            table?.reloadSections(IndexSet(integer: Section.applications.rawValue), with: .automatic)
        }
    }
    
    private lazy var upcomingInterviewsTableViewCell: UITableViewCell = {
        let cell = UITableViewCell()
        let content = cell.contentView
        cell.contentView.addSubview(upcomingInterviewsCarousel)
        upcomingInterviewsCarousel.anchor(top: content.topAnchor, leading: content.leadingAnchor, bottom: content.bottomAnchor, trailing: content.trailingAnchor)
        return cell
    }()
    
    private lazy var upcomingInterviewsCarousel: CarouselView<OfferCell> = {
        let cellSize = CGSize(width: 255, height: 291)
        return CarouselView<OfferCell>(cellSize: cellSize)
    }()

    private lazy var offersAndInterviewsTableViewCell: UITableViewCell = {
        let cell = UITableViewCell()
        let content = cell.contentView
        cell.contentView.addSubview(upcomingInterviewsCarousel)
        offersAndInterviewsCarousel.anchor(top: content.topAnchor, leading: content.leadingAnchor, bottom: content.bottomAnchor, trailing: content.trailingAnchor)
        return cell
    }()

    private var offersAndInterviewsCarousel: CarouselView<InterviewInviteCell> = {
        let cellSize = CGSize(width: 255, height: 186)
        return CarouselView<InterviewInviteCell>(cellSize: cellSize)
    }()
    
    init(coordinator: ApplicationsCoordinatorProtocol,
         service: ApplicationsService,
         isCandidateSignedIn: @escaping () -> Bool
    ) {
        self.service = service
        self.coordinator = coordinator
        self.isCandidateSignedIn = isCandidateSignedIn
    }
    
    func numberOfRows(sectionIndex: Int) -> Int {
        guard let section = Section(rawValue: sectionIndex) else { return 0 }
        switch section {
        case .upcomingInterviews, .offersAndInterviews: return 1
        case .applications: return pager.items.count
        }
    }
    
    func applicationTilePresenterForIndexPath(_ indexPath: IndexPath) -> ApplicationTilePresenter {
        let application = applicationForIndexPath(indexPath)
        return ApplicationTilePresenter(application: application)
    }
    
    func applicationForIndexPath(_ indexPath: IndexPath) -> Application {
        return applications[indexPath.row]
    }
    
    func onViewDidLoad(view: WorkfinderViewControllerProtocol) {
        self.view = view
    }
    
    func loadData(table: UITableView, completion: @escaping (Error?) -> Void) {
        table.dataSource = self
        self.table = table
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
                        self.loadApplicationsList(completion: completion)
                    }
                }
            }
        }
    }
    
    func loadOfferedApplications(completion: @escaping (Error?) -> Void) {
        service.fetchApplicationsWithOpenOffer { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let serverlistJson):
                self.offeredApplications = serverlistJson.results
                self.offersAndInterviewsCarousel.loadData(<#T##data: [[InterviewInviteData]]##[[InterviewInviteData]]#>)()
                self.table?.reloadSections(IndexSet[], with: <#T##UITableView.RowAnimation#>)
            case .failure(let error):
                completion(error)
                break
            }
        }
    }
    
    /*
     
     offered
     myInterviews.filter { interview in
         interview.status == "offered"
     }
     
     upcoming interviews
     allInterviews.filter { interview in
         interview.status == "confirmed" || interview.status == "interview meeting link added"
     }
     
     */
    
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
    
    func loadInterviews(completion: @escaping (Error?) -> Void) {
        service.fetchInterviews { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let serverlistJson):
                self.allInterviews = serverlistJson.results
            case .failure(let error):
                completion(error)
            }
        }
    }

    func loadNextPage(tableView: UITableView) {
        guard let nextPage = pager.nextPage else { return }
        pager.isLoading = true
        service.fetchNextPage(urlString: nextPage) { [weak self] (result) in
            guard let self = self else { return }
            self.pager.loadNextPage(table: tableView, with: result)
        }
    }
    
    var pager = ServerListPager<Application>()
    
    func onTapApplication(at indexPath: IndexPath) {
        let application = applicationForIndexPath(indexPath)
        let action: ApplicationAction
        switch application.state {
        case .pending: action = .viewApplication
        case .contacting: action = .viewApplication
        case .viewed: action = .viewApplication
        case .saved: action = .viewApplication
        case .declined: action = .viewApplication
        case .offered: action = .viewOffer
        case .accepted: action = .viewOffer
        case .withdrawn: action = .viewOffer
        case .expired: action = .viewApplication
        case .cancelled: action = .viewOffer
        case .unknown: action = .viewApplication
        case .interviewOffered:  action = .viewApplication
        case .interviewConfirmed: action = .viewApplication
        case .interviewMeetingLinkAdded: action = .viewApplication
        case .interviewCompleted: action = .viewApplication
        case .interviewDeclined: action = .viewApplication
        case .unroutable: action = .viewApplication
        }
        coordinator?.performAction(action, for: application, appSource: .applicationsTab)
    }
}

extension ApplicationsPresenter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .upcomingInterviews:
            return upcomingInterviews.count
        case .offersAndInterviews:
            return offeredInterviews.count
        case .applications:
            return applications.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .upcomingInterviews:
            return upcomingInterviewsTableViewCell
        case .offersAndInterviews:
            return offersAndInterviewsTableViewCell
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
