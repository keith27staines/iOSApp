import WorkfinderCommon
import UIKit

protocol CompanyMainViewPresenterRepresentable {
    func refresh()
}

protocol CompanyMainViewPresenterProtocol {
    var companyName: String { get }
    var companyLocation: LatLon { get }
    var headerViewPresenter: CompanyHeaderViewPresenterProtocol { get }
    var summarySectionPresenter: CompanySummarySectionPresenterProtocol { get }
    var dataSectionPresenter: CompanyDataSectionPresenterProtocol { get }
    var hostsSectionPresenter: CompanyHostsSectionPresenterProtocol { get }
    var applyButtonState: (String, Bool, UIColor) { get }
}


