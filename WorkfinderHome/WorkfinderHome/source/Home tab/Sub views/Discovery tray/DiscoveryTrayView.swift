
import UIKit

class DiscoveryTrayView : UIView {

    var thumbButton: UIButton!
    
    func refresh() {}
    
    func configureViews() {
        configureThumbButton()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.3
        configureViews()
    }
    
    
//    lazy var swipeDown: UISwipeGestureRecognizer = {
//        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
//        swipe.direction = .down
//        return swipe
//    }()
//
//    lazy var swipeUp: UISwipeGestureRecognizer = {
//        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
//        swipe.direction = .up
//        return swipe
//    }()
    
    @objc func handleSwipe(swipe: UISwipeGestureRecognizer) {

    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


extension DiscoveryTrayView {
    
    func configureThumbButton() {
        isUserInteractionEnabled = true
        let button = UIButton()
        //button.addTarget(self, action: #selector(changeDisplayState), for: .touchUpInside)
        button.setImage(UIImage(named: "thumbScrollIndicator"), for: .normal)
        addSubview(button)
        button.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 44, height: 44))
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        thumbButton = button
    }
}
