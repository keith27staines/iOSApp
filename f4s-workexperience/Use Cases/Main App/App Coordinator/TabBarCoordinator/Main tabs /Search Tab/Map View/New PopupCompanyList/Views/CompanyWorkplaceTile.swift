
import UIKit

class CompanyWorkplaceTile: UITableViewCell {
    
    func configureWithViewData(_ viewData: CompanyTileViewData) {
        textLabel?.text = viewData.companyName
    }
}
