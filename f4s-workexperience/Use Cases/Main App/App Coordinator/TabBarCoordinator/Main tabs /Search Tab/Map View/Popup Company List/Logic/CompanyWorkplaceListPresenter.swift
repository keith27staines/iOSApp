
import Foundation
import WorkfinderCommon

protocol CompanyWorkplaceListPresenterProtocol {
    var showLoadingIndicator: Bool { get }
    var numberOfTiles: Int { get }
    var view: CompanyWorkplaceListViewProtocol? { get set }
    func onViewDidLoad(_ view: CompanyWorkplaceListViewProtocol)
    func companyTileViewData(index: Int) -> CompanyTileViewData
    func onSelectRow(_ row: Int)
}

class CompanyWorkplaceListPresenter {
    var numberOfTiles: Int { return self.companyWorkplaces.count }
    weak var view: CompanyWorkplaceListViewProtocol?
    let provider: CompanyWorkplaceListProviderProtocol
    var showLoadingIndicator: Bool = false
    let locationUuids: [F4SUUID]
    
    init(companyWorkplaceUuids: [F4SUUID], provider: CompanyWorkplaceListProviderProtocol) {
        self.provider = provider
        self.locationUuids = companyWorkplaceUuids
    }
    
    var companyWorkplaces = [CompanyWorkplace]() {
        didSet {
            self.view?.refreshFromPresenter(self)
        }
    }
    
    var companyListJson: CompanyListJson? {
        didSet {
            guard let companyListJson = self.companyListJson else {
                companyWorkplaces = []
                return
            }
            companyWorkplaces = locationUuids.compactMap { (locationUuid) -> CompanyWorkplace? in
                guard let companyJson = self.mapCompanyToLocation(locationUuid: locationUuid, companyListJson: companyListJson) else {
                    return nil
                }
                let loc = companyJson.locations.first { (companyLocationJson) -> Bool in
                    companyLocationJson.uuid == locationUuid
                }
                let lat = loc?.point?.coordinates[0] ?? 0
                let lon = loc?.point?.coordinates[1] ?? 0
                let pinJson = PinJson(workplaceUuid: locationUuid, latitude: Double(lat), longitude: Double(lon))
                return CompanyWorkplace(companyJson: companyJson, pinJson: pinJson)
            }
            
        }
    }
    
    func mapCompanyToLocation(locationUuid: F4SUUID, companyListJson: CompanyListJson) -> CompanyJson? {
        let companyJson = companyListJson.results.first { (companyJson) -> Bool in
            companyJson.locations.contains { (companyLocationJson) -> Bool in
                return companyLocationJson.uuid == locationUuid
            }
        }
        return companyJson
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
        view?.didSelectCompanyWorkplace?(companyWorkplaces[row])
    }
    
    func onViewDidLoad(_ view: CompanyWorkplaceListViewProtocol) {
        view.presenter = self
        self.view = view
        beginFetch()
    }
    
    func companyTileViewData(index: Int) -> CompanyTileViewData {
        let companyWorkplace = companyWorkplaces[index]
        let companyJson = companyWorkplace.companyJson
        return CompanyTileViewData(companyJson: companyJson)
    }
}
