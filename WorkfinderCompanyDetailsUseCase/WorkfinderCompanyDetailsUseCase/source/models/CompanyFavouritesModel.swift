
import Foundation
import WorkfinderCommon

public protocol CompanyFavouritesModelDelegate : class {
    func companyFavouritesModelDidUpate(_ model: CompanyFavouritesModel, company: Company, isFavourite: Bool)
    func companyFavouritesModelFailedUpdate(_ model: CompanyFavouritesModel,company: Company,error: F4SNetworkError, retry: (()->Void)?)
}

public class CompanyFavouritesModel {
    let service: CompanyFavouritingServiceProtocol
    weak var delegate: CompanyFavouritesModelDelegate?
    var favouritesRepository: F4SFavouritesRepositoryProtocol
    var shortlist: [Shortlist] { return favouritesRepository.loadFavourites() }
    
    public init(
        favouritingService: CompanyFavouritingServiceProtocol,
        favouritesRepository: F4SFavouritesRepositoryProtocol) {
        self.service = favouritingService
        self.favouritesRepository = favouritesRepository
    }
    
    func isFavourite(company: Company) -> Bool {
        return shortListItemForCompany(company: company) != nil
    }
    
    func unfavourite(company: Company) {
        guard let shortlistUuid = shortListItemForCompany(company: company)?.uuid else {
            delegate?.companyFavouritesModelDidUpate(self, company: company, isFavourite: false)
            return
        }
        service.unfavourite(shortlistUuid: shortlistUuid) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                switch result {
                case .error(let error):
                    strongSelf.delegate?.companyFavouritesModelFailedUpdate(strongSelf, company: company, error: error, retry: {
                        strongSelf.unfavourite(company: company)
                    })
                case .success(_):
                    strongSelf.favouritesRepository.removeFavourite(uuid: shortlistUuid)
                    strongSelf.delegate?.companyFavouritesModelDidUpate(strongSelf, company: company, isFavourite: false)
                }
            }
        }
    }
    
    func favourite(company: Company) {
        guard !isFavourite(company: company) else {
            delegate?.companyFavouritesModelDidUpate(self, company: company, isFavourite: true)
            return
        }
        service.favourite(companyUuid: company.uuid) { [weak self] (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                switch result {
                case .error(let error):
                    strongSelf.delegate?.companyFavouritesModelFailedUpdate(strongSelf, company: company, error: error, retry: {
                        strongSelf.favourite(company: company)
                    })

                case .success(let shortlistItem):
                    let shortlistUuid = shortlistItem.uuid!
                    let shortlistedCompany = Shortlist(companyUuid: company.uuid, uuid: shortlistUuid, date: Date())
                    strongSelf.favouritesRepository.addFavourite(shortlistedCompany)
                    strongSelf.delegate?.companyFavouritesModelDidUpate(strongSelf, company: company, isFavourite: true)
                }
            }
        }
    }
    
    func shortListItemForCompany(company: Company) -> Shortlist? {
        guard let index = shortlist.firstIndex(where: { (item) -> Bool in return item.companyUuid == company.uuid }) else {
            return nil
        }
        return shortlist[index]
    }
    
    func numberOfShortLists() -> Int {
        return shortlist.count
    }
    
    func shortlistForIndex(_ index: Int) -> Shortlist {
        return shortlist[index]
    }
    
}
