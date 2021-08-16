
import WorkfinderCommon

class DiscoverTraySectionManager {
    
    enum Section {
        case popularOnWorkfinder
//        case recommendations
        case topRoles
//        case recentRoles
    }
    
    let userRepo: UserRepositoryProtocol
    
    var isSignedIn: Bool {
        userRepo.loadUser().uuid == nil ? false :  true
    }
    
    init(userRepo: UserRepositoryProtocol = UserRepository()) {
        self.userRepo = userRepo
    }
    
    var sections: [Section] {
//        isSignedIn ? [.popularOnWorkfinder, .recommendations, .topRoles, .recentRoles] :
//                     [.popularOnWorkfinder, .topRoles, .recentRoles]
        [.popularOnWorkfinder, .topRoles]
    }
    
    func sectionForSectionIndex(_ index: Int) -> Section {
        sections[index]
    }
    
    func sectionIndexForSection(_ section: Section) -> Int? {
        sections.firstIndex(of: section)
    }

}
