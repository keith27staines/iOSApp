
import UIKit

fileprivate let primaryButtonHeight = CGFloat(50)
fileprivate let primaryButtonFont = UIFont.boldSystemFont(ofSize: 17)
fileprivate let primaryButtonCornerRadius = CGFloat(8)

public class WorkfinderPrimaryButton: UIButton {
    
    public init() {
        super.init(frame: CGRect.zero)
        layer.cornerRadius = primaryButtonCornerRadius
        layer.masksToBounds = true
        setBackgroundColor(color: WorkfinderColors.primaryColor, forUIControlState: .normal)
        setBackgroundColor(color: UIColor(red: 229, green: 229, blue: 229), forUIControlState: .disabled)
        setBackgroundColor(color: WorkfinderColors.greenColorBright, forUIControlState: .highlighted)
        setTitleColor(UIColor.white, for: UIControl.State.normal)
        setTitleColor(UIColor(red: 74, green: 74, blue: 74), for: .disabled)
        titleLabel?.font = primaryButtonFont
        heightAnchor.constraint(equalToConstant: primaryButtonHeight).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class WorkfinderPrimaryGradientButton: UIButton {
    
    let animationLength = TimeInterval(0.3)
    
    var radius: CGFloat { frame.size.height / 2 }
    
    public init() {
        super.init(frame: CGRect.zero)
        layer.cornerRadius = radius
        layer.masksToBounds = true
        setBackgroundColor(color: UIColor(red: 229, green: 229, blue: 229), forUIControlState: .disabled)
        setTitleColor(UIColor.white, for: UIControl.State.normal)
        setTitleColor(UIColor(red: 74, green: 74, blue: 74), for: .disabled)
        titleLabel?.font = primaryButtonFont
        heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private lazy var normalGradientLayer: CAGradientLayer = {
        let startColor = UIColor(red:5, green:134, blue:41)
        let endColor = UIColor(red:14, green:190, blue:64)
        let gradientLayer = makeGradientLayer(startColor: startColor, endColor: endColor, isHidden: false)
        layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }()
    
    private lazy var selectedGradientLayer: CAGradientLayer = {
        let startColor = UIColor(netHex: 0x50AA6A)
        let endColor = UIColor(netHex: 0x56CD78)
        let gradientLayer = makeGradientLayer(startColor: startColor, endColor: endColor, isHidden: true)
        layer.insertSublayer(gradientLayer, at: 1)
        return gradientLayer
    }()
    
    private func makeGradientLayer(startColor: UIColor, endColor: UIColor, isHidden: Bool) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = radius
        gradientLayer.opacity = isHidden ? 0 : 1
        return gradientLayer
    }
        
    public override func layoutSubviews() {
        super.layoutSubviews()
        normalGradientLayer.frame = bounds
        selectedGradientLayer.frame = bounds
        normalGradientLayer.cornerRadius = radius
        selectedGradientLayer.cornerRadius = radius
    }
  
    public override var isHighlighted: Bool {
        didSet {
            let isHighlighted = self.isHighlighted
            UIView.animate(withDuration: 0.3) {
                self.selectedGradientLayer.opacity = isHighlighted ? 1 : 0
                self.normalGradientLayer.opacity = isHighlighted ? 0 : 1
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class WorkfinderSecondaryButton: UIButton {
    
    public init() {
        super.init(frame: CGRect.zero)
        layer.cornerRadius = primaryButtonCornerRadius
        layer.masksToBounds = true
        layer.borderColor = WorkfinderColors.primaryColor.cgColor
        layer.borderWidth = 2
        setBackgroundColor(color: UIColor.clear, forUIControlState: .normal)
        setTitleColor(WorkfinderColors.primaryColor, for: UIControl.State.normal)
        setTitleColor(WorkfinderColors.darkGrey, for: .disabled)
        titleLabel?.font = primaryButtonFont
        heightAnchor.constraint(equalToConstant: primaryButtonHeight).isActive = true
    }
    
    public override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            let enabledColor = WorkfinderColors.primaryColor.cgColor
            let disabledColor = WorkfinderColors.lightGrey.cgColor
            layer.borderColor = isEnabled ? enabledColor : disabledColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
