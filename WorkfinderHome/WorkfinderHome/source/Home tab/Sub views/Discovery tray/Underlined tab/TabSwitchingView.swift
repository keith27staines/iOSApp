
import UIKit


class TabSwitchingView: UIView {
    
    var tabs = [Tab]()
    var didSelectTab: ((Tab) -> Void)?
    var selectedTab: Tab? {
        tabs.first { (tab) -> Bool in tab.isSelected }
    }
    
    func setTabBadgeText(_ text: String?, index: Int) {
        tabs[index].badgeText = text
    }
    
    func selectTab(_ index: Int, notify: Bool) {
        let tab = tabs[0]
        selectTab(tab, notify: notify)
    }
    
    func selectTab(_ tab: Tab, notify: Bool) {
        tabs.forEach { (otherTab) in
            otherTab.isSelected = false
        }
        tab.isSelected = true
        if notify {didSelectTab?(tab)}
    }
    
    init(titles: [String]) {
        super.init(frame: CGRect.zero)
        addSubview(tabStack)
        tabStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        titles.forEach { (title) in
            appendTab(title: title)
        }
    }
    
    lazy var tabStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    @discardableResult func appendTab(title: String) -> Tab {
        let tab = Tab(index: tabs.count, title: title) { [weak self] (tab) in
            self?.selectTab(tab, notify: true)
        }
        tabs.append(tab)
        tabStack.addArrangedSubview(tab)
        return tab
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

