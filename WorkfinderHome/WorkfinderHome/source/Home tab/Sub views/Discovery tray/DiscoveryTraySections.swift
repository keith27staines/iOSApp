
import WorkfinderCommon

class DiscoverTraySectionManager {
    
    enum Section {
        case featuredOnWorkfinder
        case popularOnWorkfinder
    }
    
    let userRepo: UserRepositoryProtocol
    
    var isSignedIn: Bool {
        userRepo.loadUser().uuid == nil ? false :  true
    }
    
    init(userRepo: UserRepositoryProtocol = UserRepository()) {
        self.userRepo = userRepo
    }
    
    var sections: [Section] {
        [.popularOnWorkfinder, .featuredOnWorkfinder]
    }
    
    func sectionForSectionIndex(_ index: Int) -> Section {
        sections[index]
    }
    
    func sectionIndexForSection(_ section: Section) -> Int? {
        sections.firstIndex(of: section)
    }

}
