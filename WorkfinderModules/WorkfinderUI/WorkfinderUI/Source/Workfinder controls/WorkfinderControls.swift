
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
        switchControl.thumbTintColor = WorkfinderColors.primaryColor
        switchControl.onTintColor = UIColor(red: 86/255, green: 187/255, blue: 83/255, alpha: 1)
        switchControl.backgroundColor = UIColor.white
        return switchControl
    }
}
