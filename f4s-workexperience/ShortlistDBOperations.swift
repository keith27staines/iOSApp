import Foundation
import WorkfinderCommon

class ShortlistDBOperations {
    class var sharedInstance: ShortlistDBOperations {
        struct Static {
            static let instance: ShortlistDBOperations = ShortlistDBOperations()
        }
        return Static.instance
    }

    func saveShortlist(shortlist: Shortlist) {
        ShortlistCoreDataManager.sharedInstance.saveShortlistToContext(shortlist)
    }

    func getShortlist() -> [Shortlist] {
        let shortlistDBData = ShortlistCoreDataManager.sharedInstance.getAllShortlists()
        var shortlists: [Shortlist] = []
        for shortlistDB in shortlistDBData {
            let shortlist = ShortlistDBOperations.sharedInstance.getShortlistFromShortlistDB(shortlistDB: shortlistDB)
            shortlists.append(shortlist)
        }
        return shortlists
    }

    func removeShortlistWithId(shortlistUuid: String) {
        ShortlistCoreDataManager.sharedInstance.removeShortlistWithId(shortlistUuid: shortlistUuid)
    }

    fileprivate func getShortlistFromShortlistDB(shortlistDB: ShortlistDB) -> Shortlist {
        var shortlist: Shortlist = Shortlist()
        if let uuid = shortlistDB.uuid {
            shortlist.uuid = uuid
        }
        if let companyUuid = shortlistDB.companyUuid {
            shortlist.companyUuid = companyUuid
        }
        if let date = shortlistDB.date {
            shortlist.date = date
        }
        return shortlist
    }
}
