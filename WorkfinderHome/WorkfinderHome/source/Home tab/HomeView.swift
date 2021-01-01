
import UIKit
import WorkfinderUI

class HomeView: UIView {
    
    lazy var headerView: HeaderView = HeaderView()
    lazy var backgroundView: BackgroundView = BackgroundView()
    
    var headerVerticalOffset = CGFloat(0) {
        didSet {
            headerTopConstraint.constant = headerVerticalOffset
        }
    }
    private lazy var headerTopConstraint: NSLayoutConstraint = {
        let constraint = headerView.topAnchor.constraint(equalTo: topAnchor, constant: headerVerticalOffset)
        constraint.isActive = true
        return constraint
    }()
    
    func refresh() {
        headerView.refresh()
        backgroundView.refresh()
    }
    
    func configureViews() {
        backgroundColor = WorkfinderColors.primaryColor
        addSubview(backgroundView)
        addSubview(headerView)
        headerView.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        backgroundView.anchor(top: safeAreaLayoutGuide.topAnchor, leading: headerView.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: headerView.trailingAnchor)
    }
    
}
