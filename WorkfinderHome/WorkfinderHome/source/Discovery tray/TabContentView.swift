
import UIKit


class TabContentView: UIView {
    
    var didSwipeLeft: (() -> Void)?
    var didSwipeRight: (() -> Void)?
    
    init(tab: Tab, didSwipeLeft: @escaping () -> Void, didSwipeRight: @escaping () -> Void) {
        self.didSwipeLeft = didSwipeLeft
        self.didSwipeRight = didSwipeRight
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = true
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "UI for\(tab.title) tab"
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        addGestureRecognizer(swipeLeft)
        addGestureRecognizer(swipeRight)
    }
    
    @objc func handleSwipeLeft() {
        didSwipeLeft?()
    }
    
    @objc func handleSwipeRight() { didSwipeRight?() }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
