
import UIKit

public struct WorkfinderColors {
    public static let primaryGreen = UIColor(red: 57, green: 167, blue: 82)
    public static let greenLight = UIColor(red: 63, green: 172, blue: 87)
    public static let greenDark = UIColor(red: 52, green: 162, blue: 77)
    public static let highlightBlue = UIColor.blue
    public static let lightGrey = UIColor(white: 0.93, alpha: 1)
    public static let darkGrey = UIColor(white: 0.7, alpha: 1)
    public static let warmGrey = UIColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 1)
    public static let warningNormal = UIColor(red: 1, green: 174/255, blue: 66/255)
    public static let warningActive = UIColor(red: 63, green: 172, blue: 87)
    public static let goodValueActive = UIColor(red: 63, green: 172, blue: 87)
    public static let badValueNormal = UIColor(red: 1, green: 174/255, blue: 66/255)
    public static let badValueActive = UIColor(red: 1, green: 179/255, blue: 71/255)
}

public var workfinderGreen = WorkfinderColors.primaryGreen
public var workfinderLightGrey = WorkfinderColors.lightGrey
public var workfinderDarkGrey = WorkfinderColors.darkGrey

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
