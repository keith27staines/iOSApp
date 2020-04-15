
import UIKit

let workfinderGreen = UIColor(red: 57, green: 167, blue: 82)
let workfinderLightGrey = UIColor.init(white: 0.93, alpha: 1)
let workfinderDarkGrey = UIColor.init(white: 0.7, alpha: 1)

public class WorkfinderPrimaryButton: UIButton {
    
    public init() {
        super.init(frame: CGRect.zero)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        setBackgroundColor(color: workfinderGreen, forUIControlState: .normal)
        setBackgroundColor(color: workfinderLightGrey, forUIControlState: .disabled)
        setTitleColor(UIColor.white, for: UIControl.State.normal)
        setTitleColor(workfinderDarkGrey, for: .disabled)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
