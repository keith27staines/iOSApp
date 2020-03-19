import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol CompanyHeaderViewPresenterRenderable: class {
    func refresh(from presenter: CompanyHeaderViewPresenterProtocol)
}

protocol CompanyHeaderViewPresenterProtocol: class {
    var headerView: CompanyHeaderViewPresenterRenderable? { get set }
    var companyName: String { get }
    var logoUrlString: String { get }
    var distanceFromCompany: String { get }
    func onDidInitialise()
}

class CompanyHeaderViewPresenter: CompanyHeaderViewPresenterProtocol {
    
    weak var headerView: CompanyHeaderViewPresenterRenderable?
    let model: CompanyWorkplace
    
    init(headerView: CompanyHeaderViewPresenterRenderable,
         companyWorkplace: CompanyWorkplace) {
        self.headerView = headerView
        self.model = companyWorkplace
    }
    
    var companyName: String { model.companyJson.name }
    var logoUrlString: String { model.companyJson.logoUrlString ?? "badUrl" }
    private (set) var distanceFromCompany: String = "unknown distance"
    
    func onDidInitialise() {
        headerView?.refresh(from: self)
    }
     
}
