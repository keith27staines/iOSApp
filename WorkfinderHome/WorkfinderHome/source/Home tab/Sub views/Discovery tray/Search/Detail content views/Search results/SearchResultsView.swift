
import UIKit
import WorkfinderUI

class SearchResultsView: UIView {
    
    var queryString: String? {
        didSet {
            print("searching... [\(queryString ?? "No search string")]")
        }
    }
    
    lazy var tabSwitchingView: TabSwitchingView = {
        let view = TabSwitchingView(titles: []) { (tab) in
            
        }
        view.appendTab(title: "Roles")
        view.appendTab(title: "Companies")
        view.appendTab(title: "People")
        return view
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    func configureViews() {
        addSubview(tabSwitchingView)
        tabSwitchingView.translatesAutoresizingMaskIntoConstraints = false
        tabSwitchingView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 0))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
