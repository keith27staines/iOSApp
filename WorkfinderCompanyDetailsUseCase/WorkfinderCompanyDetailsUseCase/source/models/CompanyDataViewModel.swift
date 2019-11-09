

import Foundation
import WorkfinderCommon

struct NameValueDescriptor {
    var name: String = "name"
    var value: String = ""
    var isButton: Bool = false
    var buttonImage: UIImage? = nil
}

class CompanyDataViewModel {
    var numberOfRows: Int { return items.count }
    
    var items: [NameValueDescriptor]
    
    func nameValueForRow(_ row: Int) -> NameValueDescriptor {
        return items[row]
    }
    let annualRevenueName = "Annual Revenue"
    let annualGrowthName = "Annual Growth"
    let numberOfEmployeesName = "Number of employees"
    let seeMoreName = "See more"
    
    init(viewData: CompanyViewData) {
        let revenue = viewData.revenueString
        let growth = viewData.growthString
        let employees = viewData.employeesString

        var items = [
            NameValueDescriptor(name: annualRevenueName, value: revenue, isButton: false),
            NameValueDescriptor(name: annualGrowthName, value: growth, isButton: false),
            NameValueDescriptor(name: numberOfEmployeesName, value: employees, isButton: false)]
        if !viewData.duedilIsHiden {
            let duedilImage = UIImage(named: "ui-duedil-icon")
            let duedilText = "see more on DueDil"
            items.append(NameValueDescriptor(name: seeMoreName, value: duedilText, isButton: true, buttonImage: duedilImage))
        }
        self.items = items
    }
    
}
