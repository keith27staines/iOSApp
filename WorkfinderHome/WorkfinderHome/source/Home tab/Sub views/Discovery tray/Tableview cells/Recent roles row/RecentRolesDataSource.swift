
import UIKit
import WorkfinderUI
import WorkfinderServices

class RecentRolesDataSource: CellPresenter {
    private lazy var rolesService: RolesServiceProtocol = RolesService()
    var resultHandler: ((Error?) -> Void)?
    private var roles = [RoleData]()
    private var images = [UIImage]()
    var error:Error? = nil
    
    var result: Result<[RoleData], Error>? {
        didSet {
            guard let result = result else { return }
            switch result {
            case .success(let roles):
                self.roles = roles
                self.images = self.makeDefaultImages()
                self.error = nil
            case .failure(let error):
                self.error = error
            }
            self.resultHandler?(self.error)
            self.loadImages(roles: roles)
        }
    }
    
    var numberOfRows:Int { roles.count }
    var reloadRow: ((Int) -> Void)?
    var imageService: SmallImageServiceProtocol = SmallImageService()
    
    func roleForRow(_ row: Int) -> RoleData { roles[row] }
    
    func imageForRow(_ row: Int) -> UIImage {
        images[row]
    }
    
    private func makeDefaultImages() -> [UIImage] {
        roles.map { (role) -> UIImage in
            UIImage.imageWithFirstLetter(
                string: role.companyName ?? "Company name",
                backgroundColor: WorkfinderColors.primaryColor,
                width: 68)
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
    
    init() {
    }
    

    func loadData() {
        rolesService.fetchRoles { [weak self] (result) in
            self?.result = result
        }
    }
    
}
