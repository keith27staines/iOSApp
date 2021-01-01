
import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderServices

class RecentRolesDataSource: CellPresenter {
    private var roles = [RoleData]()
    private var images = [UIImage]()
    
    weak var messageHandler: HSUserMessageHandler?
    let rolesService: RolesServiceProtocol
    var resultHandler: ((Error?) -> Void)?

    var error:Error? = nil
    var serverListJson: ServerListJson<RoleData>?
    var numberOfRows:Int { roles.count }
    var reloadRow: ((Int) -> Void)?
    var imageService: SmallImageServiceProtocol = SmallImageService()
    
    func roleForRow(_ row: Int) -> RoleData { roles[row] }
    
    func imageForRow(_ row: Int) -> UIImage { images[row] }
    
    private func makeDefaultImages(roles: [RoleData]) -> [UIImage] {
        roles.map { (role) -> UIImage in
            UIImage.imageWithFirstLetter(
                string: role.companyName ?? "Company name",
                backgroundColor: WorkfinderColors.primaryColor,
                width: 68)
        }
    }
    
    init(rolesService: RolesServiceProtocol, messageHandler: HSUserMessageHandler?) {
        self.rolesService = rolesService
        self.messageHandler = messageHandler
    }

    func loadFirstPage(completion: @escaping () -> Void) {
        clear()
        loadNextPage(completion: completion)
    }
    
    private var allResultsCount: Int = 0
    private var nextPageUrlString: String?
    
    func clear() {
        error = nil
        allResultsCount = 0
        nextPageUrlString = nil
        result = nil
        roles = []
        images = []
    }
    
    func loadNextPage(completion: @escaping () -> Void) {
        guard roles.count < allResultsCount || roles.count == 0 else { return }
        messageHandler?.showLoadingOverlay(style: .transparent)
        rolesService.fetchRecentRoles(urlString: nextPageUrlString) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.messageHandler?.hideLoadingOverlay()
                switch result {
                case .success(_):
                    self.result = result
                    completion()
                case .failure(let error):
                    self.handleError(error: error, retry: {self.loadNextPage(completion: completion)})
                }
            }
        }
    }
    
    var lastIndexChangeSet = [Int]()

    private var result: Result<ServerListJson<RoleData>, Error>? {
        didSet {
            guard let result = result else { return }
            switch result {
            case .success(let serverListJson):
                self.serverListJson = serverListJson
                self.nextPageUrlString = serverListJson.next
                self.allResultsCount = serverListJson.count ?? 0
                let lower = self.roles.count
                let upper = lower + serverListJson.results.count - 1
                lastIndexChangeSet = Array(lower ... upper)
                let deltaRoles = serverListJson.results.settingAppSource(.homeTabRecentRolesList)
                self.roles += deltaRoles
                self.images += self.makeDefaultImages(roles: deltaRoles)
                self.error = nil
            case .failure(let error):
                self.error = error
            }
            self.resultHandler?(self.error)
            self.loadImages(roles: roles)
        }
    }
    
    private func loadImages(roles: [RoleData]) {
        for i in 0..<roles.count {
            let urlString = roles[i].companyLogoUrlString
            imageService.fetchImage(urlString: urlString, defaultImage: images[i]) { [weak self] (image) in
                guard let self = self, let image = image else { return }
                self.images[i] = image
                self.reloadRow?(i)
            }
        }
    }
    
    func handleError(error: Error, retry: @escaping () -> Void) {
        guard let wfError = error as? WorkfinderError else { return }
        wfError.retryHandler = retry
        NotificationCenter.default.post(name: .wfHomeScreenErrorNotification, object: error)
    }
    
}
