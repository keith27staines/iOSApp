
import UIKit
import WorkfinderUI

class DiscoveryTrayController {
    
    let parentView: UIView
    let tray: DiscoveryTrayView
    let topConstraint: NSLayoutConstraint
    
    var topConstraintConstant: CGFloat = 0 {
        didSet {
            topConstraintConstant = max(guide.layoutFrame.minY + 20, topConstraintConstant)
            topConstraintConstant = min(guide.layoutFrame.maxY - 20, topConstraintConstant)
            topConstraint.constant = topConstraintConstant
        }
    }
    
    lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        return pan
    }()
    
    var lastLocation: CGPoint?
    
    @objc func didPan(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: parentView)
        let velocity = sender.velocity(in: parentView)
        let translation = sender.translation(in: parentView)
        guard abs(velocity.y) > abs(velocity.x) else { return }
        if sender.state == .began {
            lastLocation = location
        } else if sender.state == .changed {
            topConstraintConstant += location.y - (lastLocation?.y ?? 0)
            lastLocation = location
        } else if sender.state == .ended {
            lastLocation = nil
        }
    }
    
    init(parentView: UIView) {
        self.parentView = parentView
        tray = DiscoveryTrayView()
        let guide = parentView.safeAreaLayoutGuide
        topConstraintConstant = guide.layoutFrame.height/2.0
        topConstraint = tray.topAnchor.constraint(equalTo: guide.topAnchor, constant: topConstraintConstant)
        configureTray()
    }
    
    var guide: UILayoutGuide { parentView.safeAreaLayoutGuide }
    
    func configureTray() {
        parentView.addSubview(tray)
        tray.anchor(top: nil, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor)
        tray.heightAnchor.constraint(equalTo: parentView.heightAnchor).isActive = true
        tray.addGestureRecognizer(pan)
        topConstraint.isActive = true
    }
    
}
