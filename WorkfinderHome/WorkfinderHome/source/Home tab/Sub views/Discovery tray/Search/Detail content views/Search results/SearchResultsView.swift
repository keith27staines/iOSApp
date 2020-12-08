
import UIKit
import WorkfinderUI

class SearchResultsView: UIView {
    
    var controller: SearchResultsController? {
        didSet {
            controller?.view = self
            configureViews()
            tabSwitchingView.didSelectTab = controller?.tabTapped
            //controller?.selectedTabIndex = 0
            tabSwitchingView.selectTab(0)
        }
    }
    
    var tableViews = [UITableView]()
    lazy var tabContent: UIView = {
        let view = UIView()
        addSubview(view)
        return view
    }()
    
    lazy var tabSwitchingView: TabSwitchingView = {
        let view = TabSwitchingView(titles: [])
        controller?.tabNames.forEach({ (name) in
            let tab = view.appendTab(title: name)
            addTableView(tab.index)
        })
        return view
    }()
    
    func addTableView(_ tag: Int) {
        let table = UITableView()
        table.tag = tag
        table.isHidden = true
        tableViews.append(table)
        tabContent.addSubview(table)
        table.anchor(top: tabContent.topAnchor, leading: tabContent.leadingAnchor, bottom: tabContent.bottomAnchor, trailing: tabContent.trailingAnchor)
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    func updateFromController() {
        guard let controller = controller else { return }
        displayContentFor(tabIndex: controller.selectedTabIndex)
    }
    
    func displayContentFor(tabIndex: Int) {
        for i in 0 ..< tableViews.count {
            tableViews[i].isHidden = i != tabIndex
        }
    }
    
    func configureViews() {
        addSubview(tabSwitchingView)
        addSubview(tabContent)
        tabSwitchingView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 0))
        tabContent.anchor(top: tabSwitchingView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 12, left: 20, bottom: 20, right: 20))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
