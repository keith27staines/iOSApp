import Foundation
import WorkfinderCommon
import WorkfinderAppLogic

class AcceptOfferContext {
    var companyJson: F4SCompanyJson
    var company: Company
    var placement: F4STimelinePlacement
    var user: F4SUser
    var companyLogo: UIImage?
    var voucherLogic: F4SVoucherLogic?
    var role: F4SRoleJson?
    var offerImage: UIImage?
    
    init(user: F4SUser, company: Company, companyJson: F4SCompanyJson, logo: UIImage?, placement: F4STimelinePlacement, role: F4SRoleJson? = nil, voucher: F4SVoucherLogic? = nil) {
        self.user = user
        self.company = company
        self.placement = placement
        self.companyLogo = logo
        self.voucherLogic = voucher
        self.role = role
        self.companyJson = companyJson
    }
    
    func presentShare(from viewController: UIViewController, sourceView: UIView) {
        guard let image = offerImage else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        guard let popoverPresentationController = activityViewController.popoverPresentationController else {
                return
        }
        popoverPresentationController.sourceView = sourceView
        popoverPresentationController.sourceRect = sourceView.bounds
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}

extension AcceptOfferContext : CustomStringConvertible {
    
    var description: String {
        return "Company: \(company.name) +\n Role: \(role?.name ?? "")"
    }
}























