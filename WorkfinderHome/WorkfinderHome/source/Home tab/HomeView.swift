
import UIKit
import WorkfinderUI

class HomeView: UIView {
    
    var headerView: HeaderView!
    var backgroundView: BackgroundView!
    var discoveryView: DiscoveryTrayView?
    
    func refresh() {
        headerView.refresh()
        backgroundView.refresh()
        discoveryView?.refresh()
    }
    
    private func addHeaderView() {
        headerView = HeaderView()
        addSubview(headerView)
        headerView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
    }

    private func addBackgroundView() {
        backgroundView = BackgroundView()
        backgroundView.backgroundColor = UIColor.white
        addSubview(backgroundView)
        backgroundView.anchor(top: headerView.bottomAnchor, leading: headerView.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: headerView.trailingAnchor)
    }
    
    private func addDiscoveryView() {
        guard self.discoveryView == nil else { return }
        let discoveryView = DiscoveryTrayView()
        self.addSubview(discoveryView)
        self.discoveryView = discoveryView
    }
    
    func configureViews() {
        addHeaderView()
        addBackgroundView()
        addDiscoveryView()
    }
}
