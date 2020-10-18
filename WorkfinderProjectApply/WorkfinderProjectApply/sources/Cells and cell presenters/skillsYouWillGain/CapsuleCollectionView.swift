
import UIKit

class CapsuleCollectionView: UIView {
    
    let radius: CGFloat
    let minimumVerticalSpacing: CGFloat
    let minimumHorizontalSpacing: CGFloat
    private var capsules: [CapsuleView] = []
    private var arrangedCapsules: [CapsuleView] = []
    private var addedConstraints = [NSLayoutConstraint]()
    private var frameWidth: CGFloat = 300
    private var x: CGFloat = 0
    
    func reload(strings: [String], width: CGFloat) {
        frameWidth = width
        clear()
        addCapsules(strings: strings)
        invalidateIntrinsicContentSize()
    }
    
    private func addCapsules(strings: [String]) {
        capsules = strings.map { (string) -> CapsuleView in
            CapsuleView(string: string, radius: radius)
        }
        capsules.forEach { (capsule) in
            addSubview(capsule)
            capsule.translatesAutoresizingMaskIntoConstraints = false
            arrangeCapsule(capsule)
        }
        if let lastCapule = arrangedCapsules.last {
            addedConstraints.append(bottomAnchor.constraint(equalTo: lastCapule.bottomAnchor, constant: minimumVerticalSpacing))
        }
        NSLayoutConstraint.activate(addedConstraints)
        invalidateIntrinsicContentSize()
    }
    
    func clear() {
        x = 0
        removeAllCapsulesFromSuperview()
        capsules = []
        arrangedCapsules = []
        arrangedCapsules = []
        addedConstraints = []
    }
    
    func willCapsuleFitOnCurrentLine(_ capsule: CapsuleView) -> Bool {
        x + capsule.intrinsicContentSize.width <= frameWidth
    }
    
    private func arrangeCapsule(_ capsule: CapsuleView) {
        if arrangedCapsules.isEmpty {
            arrangeFirstCapsule(capsule)
        } else if willCapsuleFitOnCurrentLine(capsule) {
            arrangeCapsuleToCurrentRow(capsule)
        } else {
            arrangeFirstCapsuleToNewRow(capsule)
        }
        arrangedCapsules.append(capsule)
    }
    
    func arrangeFirstCapsuleToNewRow(_ capsule: CapsuleView) {
        guard let last = arrangedCapsules.last else {
            arrangeFirstCapsule(capsule)
            return
        }
        addedConstraints.append(capsule.leadingAnchor.constraint(equalTo: leadingAnchor))
        addedConstraints.append(capsule.topAnchor.constraint(equalTo: last.bottomAnchor, constant: minimumVerticalSpacing))
        x = capsule.intrinsicContentSize.width + minimumHorizontalSpacing
    }
    
    func arrangeCapsuleToCurrentRow(_ capsule: CapsuleView) {
        guard let last = arrangedCapsules.last else {
            arrangeFirstCapsule(capsule)
            return
        }
        addedConstraints.append(capsule.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: minimumHorizontalSpacing))
        addedConstraints.append(capsule.topAnchor.constraint(equalTo: last.topAnchor))
        x += capsule.intrinsicContentSize.width + minimumHorizontalSpacing
    }
    
    func arrangeFirstCapsule(_ capsule: CapsuleView) {
        addedConstraints.append(capsule.leadingAnchor.constraint(equalTo: leadingAnchor))
        addedConstraints.append(capsule.topAnchor.constraint(equalTo: topAnchor))
        x += capsule.intrinsicContentSize.width + minimumHorizontalSpacing
    }
    
    private func removeAllCapsulesFromSuperview() {
        capsules.forEach { (capsule) in capsule.removeFromSuperview() }
    }
    
    init(capsuleRadius: CGFloat = 23, minimumHorizontalSpacing: CGFloat = 10, minimumVerticalSpacing: CGFloat = 10) {
        self.radius = capsuleRadius
        self.minimumVerticalSpacing = minimumVerticalSpacing
        self.minimumHorizontalSpacing = minimumHorizontalSpacing
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}
