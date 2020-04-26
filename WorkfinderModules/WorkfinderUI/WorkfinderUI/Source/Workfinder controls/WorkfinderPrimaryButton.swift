
import UIKit

public class WorkfinderPrimaryButton: UIButton {
    
    public init() {
        super.init(frame: CGRect.zero)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        setBackgroundColor(color: WorkfinderColors.primaryGreen, forUIControlState: .normal)
        setBackgroundColor(color: WorkfinderColors.lightGrey, forUIControlState: .disabled)
        setBackgroundColor(color: WorkfinderColors.greenLight, forUIControlState: .highlighted)
        setTitleColor(UIColor.white, for: UIControl.State.normal)
        setTitleColor(WorkfinderColors.darkGrey, for: .disabled)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
