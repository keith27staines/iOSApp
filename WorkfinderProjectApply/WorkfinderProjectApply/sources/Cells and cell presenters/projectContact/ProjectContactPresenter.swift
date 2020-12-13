
import WorkfinderCommon

protocol ProjectContactPresenterProtocol: CellPresenterProtocol {
    var photo: String? { get }
    var name: String? { get }
    var information: String? { get }
    var title: String? { get }
    var linkedIn: String? { get }
}

class ProjectContactPresenter: ProjectContactPresenterProtocol {

    let photo: String?
    let name: String?
    let information: String?
    let title: String?
    let linkedIn: String?
    var isHidden: Bool
    
    init(host: HostJson?, role: String?, isHidden: Bool = false) {
        photo = host?.photoUrlString
        name = host?.fullName
        information = host?.description
        self.title = role
        linkedIn = host?.linkedinUrlString
        self.isHidden = isHidden
    }
    
}
