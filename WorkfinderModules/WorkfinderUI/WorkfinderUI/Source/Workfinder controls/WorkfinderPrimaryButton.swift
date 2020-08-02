
import UIKit

fileprivate let primaryButtonHeight = CGFloat(50)
fileprivate let primaryButtonFont = UIFont.boldSystemFont(ofSize: 17)
fileprivate let primaryButtonCornerRadius = CGFloat(8)

public class WorkfinderPrimaryButton: UIButton {
    
    init() {
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

public class WorkfinderSecondaryButton: UIButton {
    
    init() {
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
