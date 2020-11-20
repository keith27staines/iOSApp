
import UIKit

enum DisplayState {
    case minimized
    case maximized
    var thumbImage: UIImage? {
        switch self {
        case .minimized:
            return UIImage(named: "maximise")
        case .maximized:
            return UIImage(named: "minimise")
        }
    }
}

class DiscoveryView : UIView {
    var gapAboveConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    var thumbButton: UIButton!
    var tabsView: TabSwitchingView!
    var contentView: UIView?
    
    var alwaysVisibleView: UIView!
    var alwaysVisibleHeight: CGFloat = 100
    
    var maximumTopGap: CGFloat {
        (superview?.frame.height ?? 400) - alwaysVisibleHeight
    }
    
    var gapAboveConstant: CGFloat = 100 {
        didSet {
            gapAboveConstraint.constant = min(gapAboveConstant, maximumTopGap)
            UIView.animate(
                withDuration: 1,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 2,
                options: .curveEaseOut) {
                self.superview?.layoutIfNeeded()
            } completion: { (finished) in
                
            }
        }
    }
    
    var heightConstant: CGFloat = 400 {
        didSet { heightConstraint?.constant = heightConstant }
    }
    
    @objc func changeDisplayState() {
        switch self.displayState {
        case .minimized:
            self.displayState = .maximized
        case .maximized:
            self.displayState = .minimized
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowRadius = 50
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 1
    }
    
    var displayState: DisplayState = .minimized {
        didSet {
            switch displayState {
            case .minimized:
                gapAboveConstant = maximumTopGap
            case .maximized:
                gapAboveConstant = alwaysVisibleHeight
            }
            thumbButton.setImage(displayState.thumbImage, for: .normal)
        }
    }
    
    lazy var swipeDown: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipe.direction = .down
        return swipe
    }()
    
    lazy var swipeUp: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipe.direction = .up
        return swipe
    }()
    
    
    override func didMoveToSuperview() {
        guard let superview = self.superview else { return }
        frame = CGRect(x: 0, y: superview.bounds.height*1.5, width: superview.bounds.width, height: superview.bounds.height)
        createHeightConstraint(superView: superview)
        createSideGapsTo(superview: superview)
        createTopGapConstraintTo(superview: superview)
        configureViews()
        displayState = .minimized
        addGestureRecognizer(swipeDown)
        addGestureRecognizer(swipeUp)
    }
    
    @objc func handleSwipe(swipe: UISwipeGestureRecognizer) {
        switch displayState {
        case .minimized:
            switch swipe.direction {
            case .up: displayState = .maximized
            default: break
            }
        case .maximized:
            switch swipe.direction {
            case .down: displayState = .minimized
            default: break
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


// Configure subviews
extension DiscoveryView {
    
    func configureViews() {
        configureThumbButton()
        configureDiscoveryButton()
        configureTabs()
    }
    
    func configureThumbButton() {
        let button = UIButton()
        button.addTarget(self, action: #selector(changeDisplayState), for: .touchUpInside)
        button.setImage(UIImage(named: "maximise"), for: .normal)
        addSubview(button)
        button.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 44, height: 44))
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        thumbButton = button
    }
    
    func configureDiscoveryButton() {
        let discovery = UIButton(type: .custom)
        discovery.addTarget(self, action: #selector(changeDisplayState), for: .touchUpInside)
        discovery.setTitle("Discovery", for: .normal)
        discovery.setTitleColor(UIColor.darkText, for: .normal)
        addSubview(discovery)
        discovery.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 0))
        discovery.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func configureTabs() {
        tabsView = TabSwitchingView(titles: ["Project", "Subject", "Companies"]) { (tab) in
            self.displayContentForTab(tab)
        }
        addSubview(tabsView)
        tabsView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: alwaysVisibleHeight, left: 0, bottom: 0, right: 0))
    }
    
    func contentViewForTab(_ tab: Tab) -> TabContentView {
        let content = TabContentView(
            tab: tab,
            didSwipeLeft: {
                if tab.index < 2 {
                    let newTab = self.tabsView.tabs[tab.index+1]
                    self.tabsView.selectTab(newTab)
                    self.displayContentForTab(newTab)
                }
            }, didSwipeRight: {
                if tab.index > 0 {
                    let newTab = self.tabsView.tabs[tab.index-1]
                    self.tabsView.selectTab(newTab)
                    self.displayContentForTab(newTab)
                }
            })
        return content
    }
    
    func displayContentForTab(_ tab: Tab) {
        let tabContent = contentViewForTab(tab)
        self.contentView?.removeFromSuperview()
        addSubview(tabContent)
        self.contentView = tabContent
        tabContent.anchor(top: tabsView.bottomAnchor, leading: tabsView.leadingAnchor, bottom: bottomAnchor, trailing: tabsView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}

// Create constraints to superview
extension DiscoveryView {
    
    func createHeightConstraint(superView: UIView) {
        heightConstant = (superview?.frame.height ?? 400) - alwaysVisibleHeight
        heightConstraint = heightAnchor.constraint(equalToConstant: heightConstant)
        heightConstraint.isActive = true
    }
    
    func createSideGapsTo(superview: UIView) {
        anchor(top: nil, leading: superview.leadingAnchor, bottom: nil, trailing: superview.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    func createTopGapConstraintTo(superview: UIView) {
        gapAboveConstraint?.isActive = false
        gapAboveConstraint = topAnchor.constraint(equalTo: superview.topAnchor, constant: gapAboveConstant)
        gapAboveConstraint.isActive = true
        
    }
}
