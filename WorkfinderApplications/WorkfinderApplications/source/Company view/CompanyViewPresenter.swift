
import WorkfinderCommon

class CompanyViewPresenter {
    
    let service: CompanyService
    let application: Application
    var view: CompanyViewController?
    
    let summarySectionPresenter: CompanySummarySectionPresenterProtocol
    let dataSectionPresenter: CompanyDataSectionPresenterProtocol
    
    var companyName: String? { application.companyName }
    var logoUrlString: String? { application.logoUrl }
    var distanceFromCompany: String = "unknown distance from you"
    
    func onViewDidLoad(view: CompanyViewController) {
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    var workplace: CompanyWorkplace!
    
    init(application: Application, service: CompanyService) {
        self.application = application
        self.service = service
        self.summarySectionPresenter = CompanySummarySectionPresenter(companyWorkplace: workplace)
        self.dataSectionPresenter = CompanyDataSectionPresenter(companyWorkplace: workplace)
    }
    
    lazy var sectionsModel: CompanyTableSectionsModel = {
        let model = CompanyTableSectionsModel()
        let sectionsList: [CompanyTableSectionType] = [
            .companySummary,
            .companyData
        ]
        for section in sectionsList {
            model.appendDescriptor(sectionType: section, isHidden: false)
        }
        return model
    }()
    
    func numberOfSections() -> Int {
        return sectionsModel.count
    }
    
    func numberOfRowsInSection(_ section: Int ) -> Int {
        let sectionModel = sectionsModel[section]
        switch sectionModel.sectionType {
        case .companySummary:
            return summarySectionPresenter.numberOfRows
        case .companyData:
            return dataSectionPresenter.numberOfRows
        case .companyHosts:
            return 0
        }
    }
    
    func cellForTable(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let rowInSection = indexPath.row
        let sectionModel = sectionsModel[indexPath.section]
        switch sectionModel.sectionType {
        case .companySummary:
            return summarySectionPresenter.cellForRow(rowInSection, in: tableView)
        case .companyData:
            return dataSectionPresenter.cellForRow(rowInSection, in: tableView)
        case .companyHosts:
            return UITableViewCell()
        }
    }
}
