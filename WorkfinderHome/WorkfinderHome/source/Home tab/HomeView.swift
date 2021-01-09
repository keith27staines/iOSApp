
import UIKit
import WorkfinderUI

class HomeView: UIView {

    lazy var backgroundView: BackgroundView = BackgroundView()
    
    func refresh() { backgroundView.refresh() }
    
    func configureViews() {
        backgroundColor = WorkfinderColors.primaryColor
        addSubview(backgroundView)
        let guide = safeAreaLayoutGuide
        backgroundView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor)
    }
    
}
