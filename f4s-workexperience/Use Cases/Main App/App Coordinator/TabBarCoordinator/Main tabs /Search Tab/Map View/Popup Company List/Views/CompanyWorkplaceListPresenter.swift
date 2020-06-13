
import Foundation
import WorkfinderCommon
import WorkfinderServices

protocol WorkplaceListPresenterProtocol {
    var showLoadingIndicator: Bool { get }
    var numberOfTiles: Int { get }
    var view: WorkplaceListViewProtocol? { get set }
    func onViewDidLoad(_ view: WorkplaceListViewProtocol)
    func companyTileViewData(index: Int) -> CompanyTileViewData
    func onSelectRow(_ row: Int)
    func loadData(completion: @escaping (Error?) -> Void)
}

class WorkplaceListPresenter {
    var numberOfTiles: Int { return self.Workplaces.count }
    weak var view: WorkplaceListViewProtocol?
    let provider: WorkplaceListProviderProtocol
    var showLoadingIndicator: Bool = false
    let locationUuids: [F4SUUID]
    
    init(WorkplaceUuids: [F4SUUID], provider: WorkplaceListProviderProtocol) {
        self.provider = provider
        self.locationUuids = WorkplaceUuids
    }
    
    var Workplaces = [Workplace]() {
        didSet {
            self.view?.refreshFromPresenter(self)
        }
    }
    
    var companyListJson: CompanyListJson? {
        didSet {
            guard let companyListJson = self.companyListJson else {
                Workplaces = []
                return
            }
            Workplaces = locationUuids.compactMap { (locationUuid) -> Workplace? in
                guard let companyJson = self.mapCompanyToLocation(locationUuid: locationUuid, companyListJson: companyListJson) else {
                    return nil
                }
                let loc = companyJson.locations?.first { (companyLocationJson) -> Bool in
                    companyLocationJson.uuid == locationUuid
                }
                let lat = loc?.geometry?.coordinates[1] ?? 0
                let lon = loc?.geometry?.coordinates[0] ?? 0
                let pinJson = PinJson(workplaceUuid: locationUuid, latitude: Double(lat), longitude: Double(lon))
                return Workplace(companyJson: companyJson, pinJson: pinJson)
            }
            
        }
    }
    
    func mapCompanyToLocation(locationUuid: F4SUUID, companyListJson: CompanyListJson) -> CompanyJson? {
        let companyJson = companyListJson.results.first { (companyJson) -> Bool in
            let locations = companyJson.locations ?? [CompanyLocationJson]()
            return locations.contains { (companyLocationJson) -> Bool in
                return companyLocationJson.uuid == locationUuid
            }
        }
        return companyJson
    }
    
    func beginFetch(completion: @escaping (Error?) -> Void) {
        showLoadingIndicator = true
        view?.refreshFromPresenter(self)
        provider.fetchWorkplaces(locationUuids: locationUuids) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onfetchComplete(result,completion: completion)
            }
        }
    }
    
    func onfetchComplete(_ result: Result<CompanyListJson,Error>, completion: (Error?) -> Void) {
        self.showLoadingIndicator = false
        switch result {
        case .success(let companyListJson):
            self.companyListJson = companyListJson
            self.view?.refreshFromPresenter(self)
        case .failure(let error): completion(error)
        }
    }
}

extension WorkplaceListPresenter: WorkplaceListPresenterProtocol {
    
    func onSelectRow(_ row: Int) {
        view?.didSelectWorkplace?(Workplaces[row])
    }
    
    func onViewDidLoad(_ view: WorkplaceListViewProtocol) {
        view.presenter = self
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        beginFetch(completion: completion)
    }
    
    func companyTileViewData(index: Int) -> CompanyTileViewData {
        let Workplace = Workplaces[index]
        let companyJson = Workplace.companyJson
        return CompanyTileViewData(companyJson: companyJson)
    }
}
