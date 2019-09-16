import UIKit
import WorkfinderCommon
import WorkfinderAppLogic
import WorkfinderServices

public class AcceptOfferContext {
    public var companyJson: F4SCompanyJson
    public var company: CompanyViewDataProtocol
    public var placement: F4STimelinePlacement
    public var user: F4SUser
    public var companyLogo: UIImage?
    public var role: F4SRoleJson?
    public var offerImage: UIImage?
    
    public init(user: F4SUser, company: CompanyViewDataProtocol, companyJson: F4SCompanyJson, logo: UIImage?, placement: F4STimelinePlacement, role: F4SRoleJson? = nil) {
        self.user = user
        self.company = company
        self.placement = placement
        self.companyLogo = logo
        self.role = role
        self.companyJson = companyJson
    }
    
    public func presentShare(from viewController: UIViewController, sourceView: UIView) {
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
    
    public var description: String {
        return "Company: \(company.companyName) +\n Role: \(role?.name ?? "")"
    }
}























