
import WorkfinderCommon

class DiscoverTraySectionManager {
    
    enum Section {
        case searchBar
        case popularOnWorkfinder
        case recommendations
        case topRoles
        case recentRoles
    }
    
    let userRepo: UserRepositoryProtocol
    
    var isSignedIn: Bool {
        userRepo.loadUser().uuid == nil ? false :  true
    }
    
    init(userRepo: UserRepositoryProtocol = UserRepository()) {
        self.userRepo = userRepo
    }
    
    var sections: [Section] {
        isSignedIn ? [.searchBar, .popularOnWorkfinder, .recommendations, .topRoles, .recentRoles] :
                     [.searchBar, .popularOnWorkfinder, .topRoles, .recentRoles]
    }
    
    func sectionForSectionIndex(_ index: Int) -> Section {
        sections[index]
    }
    
    func sectionIndexForSection(_ section: Section) -> Int? {
        sections.firstIndex(of: section)
    }

}
