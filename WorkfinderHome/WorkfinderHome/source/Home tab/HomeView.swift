
import UIKit
import WorkfinderUI

class HomeView: UIView {
    
    var headerView: HeaderView!
    var backgroundView: BackgroundView!
    
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
    
    private func addHeaderView() {
        headerView = HeaderView()
        addSubview(headerView)
        headerView.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
    }

    private func addBackgroundView() {
        backgroundView = BackgroundView()
        addSubview(backgroundView)
        backgroundView.anchor(top: headerView.bottomAnchor, leading: headerView.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: headerView.trailingAnchor)
    }
    
    func configureViews() {
        backgroundColor = WorkfinderColors.primaryColor
        addHeaderView()
        addBackgroundView()
    }
    
}
