import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol CompanyHeaderViewPresenterProtocol: class {
    
    var companyName: String { get }
    var logoUrlString: String { get }
    var distanceFromCompany: String { get }
    func attach(view: CompanyHeaderViewProtocol)
    func onDidInitialise()
}

class CompanyHeaderViewPresenter: CompanyHeaderViewPresenterProtocol {
    
    weak var view: CompanyHeaderViewProtocol?
    let model: CompanyWorkplace
    
    init(companyWorkplace: CompanyWorkplace) {
        self.model = companyWorkplace
    }
    
    var companyName: String { model.companyJson.name ?? "unnamed company" }
    var logoUrlString: String { model.companyJson.logoUrlString ?? "badUrl" }
    private (set) var distanceFromCompany: String = "unknown distance"
    
    func attach(view: CompanyHeaderViewProtocol) {
        self.view = view
        view.presenter = self
    }
    
    func onDidInitialise() {
        view?.refresh(from: self)
    }
     
}
