import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderAppLogic

class CompanySummaryViewController: CompanySubViewController {
    
    let documentsModel: F4SCompanyDocumentsModelProtocol
    
    init(viewModel: CompanyViewModel,
         pageIndex: CompanyViewModel.PageIndex,
         documentsModel: F4SCompanyDocumentsModelProtocol) {
        self.documentsModel = documentsModel
        super.init(viewModel: viewModel, pageIndex: pageIndex)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        refresh()
    }
    
    lazy var verticalStack: UIStackView = {
        let views: [UIView] = [
            self.industryLabel,
            self.ratingView,
            self.addressView,
            self.distanceFromYouView,
            self.descriptionView,
            self.documentsView]
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.alignment = .fill
        return stack
    }()
    
    func configureViews() {
        addSubControllers()
        view.addSubview(verticalStack)
        verticalStack.fillSuperview(padding: UIEdgeInsets(top: 20, left: 8, bottom: 20, right: 8))
    }
    
    var documentsView: UIView!
    
    func addSubControllers() {
        let vc = CompanyDocumentsViewController(documentsModel: documentsModel)
        documentsView = vc.view
        view.addSubview(documentsView)
        addChild(vc)
        vc.didMove(toParent: self)
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white
    }
    
    var companyViewData: CompanyViewData { return viewModel.companyViewData }
    
    override func refresh() {
        ratingView.rating = companyViewData.starRating ?? 0
        ratingView.isHidden = companyViewData.starRatingIsHidden
        industryLabel.text = companyViewData.industry
        industryLabel.isHidden = companyViewData.industryIsHidden
        descriptionView.text = companyViewData.description
        //moreButton.isHidden = !descriptionView.isTruncated()
        if let postcode = companyViewData.postcode {
            addressView.text = "Location: \(postcode)"
            addressView.isHidden = false
        } else {
            addressView.isHidden = true
        }
        distanceFromYouView.isHidden = viewModel.distanceFromUserToCompany == nil
        distanceFromYouView.text = viewModel.distanceFromUserToCompany
    }
    
    var industryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    var ratingView: StarRatingView = {
        let ratingView = StarRatingView()
        return ratingView
    }()
    
    lazy var descriptionView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        textView.text = ""
        textView.textAlignment = .left
        textView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        return textView
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("more...", for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        button.alpha = 0.95
        button.isHidden = true
        button.layer.cornerRadius = 8
        return button
    }()
    
    lazy var addressView: UILabel = {
        let label = UILabel()
        label.text = "Can't load address"
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        return label
    }()
    
    lazy var distanceFromYouView: UILabel = {
        let label = UILabel()
        label.text = "Distance from you: unknown"
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        return label
    }()
}

extension UILabel {
    func isTruncated() -> Bool {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        if label.frame.height > self.frame.height {
            return true
        }
        return false
    }
}
