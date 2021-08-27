
import UIKit

public class CapsuleCollectionView: UIView {
    
    let radius: CGFloat
    let minimumVerticalSpacing: CGFloat
    let minimumHorizontalSpacing: CGFloat
    private var capsules: [CapsuleView] = []
    private var arrangedCapsules: [CapsuleView] = []
    private var addedConstraints = [NSLayoutConstraint]()
    private var frameWidth: CGFloat = 300
    private var currentLineLength: CGFloat = 0
    private var widthConstraint: NSLayoutConstraint?
    
    public func reload(strings: [String], width: CGFloat) {
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
            addedConstraints.append(bottomAnchor.constraint(equalTo: lastCapule.bottomAnchor, constant: 0))
        }
        widthConstraint?.constant = intrinsicWidth
        NSLayoutConstraint.activate(addedConstraints)
        invalidateIntrinsicContentSize()
    }
    
    func clear() {
        intrinsicWidth = 0
        currentLineLength = 0
        removeAllCapsulesFromSuperview()
        capsules = []
        arrangedCapsules = []
        addedConstraints = []
    }
    
    func willCapsuleFitOnCurrentLine(_ capsule: CapsuleView) -> Bool {
        currentLineLength + capsule.intrinsicContentSize.width <= frameWidth
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
    
    var intrinsicWidth = CGFloat(0)
    
    func arrangeFirstCapsuleToNewRow(_ capsule: CapsuleView) {
        guard let last = arrangedCapsules.last else {
            arrangeFirstCapsule(capsule)
            return
        }
        addedConstraints.append(capsule.leadingAnchor.constraint(equalTo: leadingAnchor))
        addedConstraints.append(capsule.topAnchor.constraint(equalTo: last.bottomAnchor, constant: minimumVerticalSpacing))
        currentLineLength = capsule.intrinsicContentSize.width + minimumHorizontalSpacing
        if currentLineLength - minimumHorizontalSpacing > intrinsicWidth {
            intrinsicWidth = currentLineLength - minimumHorizontalSpacing
        }
    }
    
    func arrangeCapsuleToCurrentRow(_ capsule: CapsuleView) {
        guard let last = arrangedCapsules.last else {
            arrangeFirstCapsule(capsule)
            return
        }
        addedConstraints.append(capsule.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: minimumHorizontalSpacing))
        addedConstraints.append(capsule.topAnchor.constraint(equalTo: last.topAnchor))
        currentLineLength += capsule.intrinsicContentSize.width + minimumHorizontalSpacing
        if currentLineLength - minimumHorizontalSpacing > intrinsicWidth {
            intrinsicWidth = currentLineLength - minimumHorizontalSpacing
        }
    }
    
    func arrangeFirstCapsule(_ capsule: CapsuleView) {
        addedConstraints.append(capsule.leadingAnchor.constraint(equalTo: leadingAnchor))
        addedConstraints.append(capsule.topAnchor.constraint(equalTo: topAnchor))
        currentLineLength += capsule.intrinsicContentSize.width + minimumHorizontalSpacing
        intrinsicWidth = capsule.intrinsicContentSize.width
    }
    
    private func removeAllCapsulesFromSuperview() {
        capsules.forEach { (capsule) in capsule.removeFromSuperview() }
    }
    
    public init(capsuleRadius: CGFloat = 23, minimumHorizontalSpacing: CGFloat = 10, minimumVerticalSpacing: CGFloat = 10) {
        self.radius = capsuleRadius
        self.minimumVerticalSpacing = minimumVerticalSpacing
        self.minimumHorizontalSpacing = minimumHorizontalSpacing
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        widthConstraint = widthAnchor.constraint(equalToConstant: intrinsicWidth)
        widthConstraint?.isActive = true
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}
