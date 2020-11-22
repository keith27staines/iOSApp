
import UIKit
import WorkfinderUI

class HomeView: UIView {
    
    var headerView: HeaderView!
    var backgroundView: UIView!
    var discoveryView: DiscoveryView?
    
    func addHeaderView() {
        headerView = HeaderView(frame: .zero)
        addSubview(headerView)
        headerView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
    }

    func addBackgroundView() {
        backgroundView = BackgroundView()
        backgroundView.backgroundColor = UIColor.white
        addSubview(backgroundView)
        backgroundView.anchor(top: headerView.bottomAnchor, leading: headerView.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: headerView.trailingAnchor)
    }
    
    func addDiscoveryView() {
        guard self.discoveryView == nil else { return }
        let discoveryView = DiscoveryView()
        self.addSubview(discoveryView)
        self.discoveryView = discoveryView
    }
    
    func configureViews() {
        addHeaderView()
        addBackgroundView()
        addDiscoveryView()
    }
}
