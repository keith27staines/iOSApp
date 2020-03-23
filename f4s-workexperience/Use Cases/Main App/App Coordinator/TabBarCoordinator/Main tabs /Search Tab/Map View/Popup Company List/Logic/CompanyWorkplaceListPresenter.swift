
import Foundation

protocol CompanyWorkplaceListPresenterProtocol {
    var showLoadingIndicator: Bool { get }
    var numberOfTiles: Int { get }
    var view: CompanyWorkplaceListViewProtocol? { get set }
    func onViewDidLoad(_ view: CompanyWorkplaceListViewProtocol)
    func companyTileViewData(index: Int) -> CompanyTileViewData
    func onSelectRow(_ row: Int)
}

class CompanyWorkplaceListPresenter {
    var numberOfTiles: Int { return self.companyTiles.count }
    weak var view: CompanyWorkplaceListViewProtocol?
    let provider: CompanyWorkplaceListProviderProtocol
    var showLoadingIndicator: Bool = false
    var companyTiles: [CompanyTileViewData]
    let locationUuids: [F4SUUID]
    
    init(companyWorkplaceUuids: [F4SUUID], provider: CompanyWorkplaceListProviderProtocol) {
        self.provider = provider
        self.locationUuids = ["4764e857-51ac-4b82-a97d-6a502c2d4dad"]
        //self.locationUuids = companyWorkplaceUuids
        self.companyTiles = []
    }
    
    var companyListJson: CompanyListJson? {
        didSet {
            defer { view?.refreshFromPresenter(self) }
            guard let companyListJson = self.companyListJson else {
                self.companyTiles = []
                return
            }
            self.companyTiles = companyListJson.results.map({ (companyJson) -> CompanyTileViewData in
                return CompanyTileViewData(companyJson: companyJson)
            })
        }
    }
    
    func beginFetch() {
        showLoadingIndicator = true
        view?.refreshFromPresenter(self)
        provider.fetchCompanyWorkplaces(locationUuids: locationUuids) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onfetchComplete(result)
            }
        }
    }
    
    func onfetchComplete(_ result: Result<Data,Error>) {
        self.showLoadingIndicator = false
        switch result {
        case .success(let data):
            self.decode(data)
            self.view?.refreshFromPresenter(self)
        case .failure(let error):
            print(error)
            break
        }
    }
    
    func decode(_ data: Data) {
        do {
            self.companyListJson = try JSONDecoder().decode(CompanyListJson.self, from: data)
        } catch {
            companyListJson = nil
        }
    }
}

extension CompanyWorkplaceListPresenter: CompanyWorkplaceListPresenterProtocol {
    
    func onSelectRow(_ row: Int) {
        let company = companyTiles[row]
    }
    
    func onViewDidLoad(_ view: CompanyWorkplaceListViewProtocol) {
        view.presenter = self
        self.view = view
        beginFetch()
    }
    
    func companyTileViewData(index: Int) -> CompanyTileViewData {
        return companyTiles[index]
    }
}
