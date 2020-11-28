
import UIKit
import WorkfinderUI
import WorkfinderServices

class RecentRolesDataSource: CellPresenter {
    lazy var rolesService: RolesServiceProtocol = RolesService()
    var resultHandler: ((Error?) -> Void)?
    private var roles = [RoleData]()
    var error:Error? = nil
    var result: Result<[RoleData], Error>? {
        didSet {
            guard let result = result else { return }
            switch result {
            case .success(let roles):
                self.roles = roles
                self.error = nil
            case .failure(let error):
                self.error = error
            }
            self.resultHandler?(self.error)
        }
    }
    
    var numberOfRows:Int { roles.count }
    
    func roleForRow(_ row: Int) -> RoleData { roles[row] }
    
    var images = [Int:UIImage]()
    
    func imageForRow(_ row: Int) -> UIImage {
        let role = roleForRow(row)
        let defaultImage = UIImage.imageWithFirstLetter(
            string: role.companyName,
            backgroundColor: WorkfinderColors.primaryColor,
            width: 68)
        let image = UIImage()
        return image
    }
    
    init() {
    }
    
    func loadData() {
        rolesService.fetchRoles { [weak self] (result) in
            self?.result = result
        }
    }
    
    var imageService: SmallImageServiceProtocol = SmallImageService()
    
    func loadImage() {
        imageService.fetchImage(
            urlString: companyLogoUrlString,
            defaultImage: defaultImage) { [weak self] (image) in
                guard let self = self else { return }
                self.downloadedImage = image
                self.parentPresenter?.refreshRow(self.row)
        }
    }
}
