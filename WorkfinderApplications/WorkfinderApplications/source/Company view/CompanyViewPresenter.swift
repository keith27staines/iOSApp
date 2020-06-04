
import WorkfinderCommon

class CompanyViewPresenter {
    
    let service: CompanyService
    let application: Application
    var view: CompanyViewController?
    
    func onViewDidLoad(view: CompanyViewController) {
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    init(application: Application, service: CompanyService) {
        self.application = application
        self.service = service
    }
}
