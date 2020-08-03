
import UIKit

public struct WorkfinderControls {
    
    public static func makePrimaryButton() -> WorkfinderPrimaryButton {
        WorkfinderPrimaryButton()
    }
    
    public static func makeSecondaryButton() -> WorkfinderSecondaryButton {
        WorkfinderSecondaryButton()
    }
    
    public static func makeSwitch() -> UISwitch {
        let switchControl = UISwitch()
        switchControl.thumbTintColor = UIColor.white
        switchControl.onTintColor = WorkfinderColors.primaryColor
        switchControl.backgroundColor = UIColor.white
        return switchControl
    }
}
