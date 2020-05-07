import UIKit

public struct WorkfinderColors {
    public static let primaryColor = UIColor(red: 57, green: 167, blue: 82)
    public static let greenColorBright = UIColor(red: 63, green: 172, blue: 87)
    public static let greenColorDark = UIColor(red: 52, green: 162, blue: 77)
    
    public static let highlightBlue = UIColor.blue
    public static let oceanBlue = UIColor(red: 0, green: 200, blue: 255)
    public static let lightGrey = UIColor(white: 0.93, alpha: 1)
    public static let darkGrey = UIColor(white: 0.7, alpha: 1)
    public static let warmGrey = UIColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 1)
    
    public static var goodValueNormal: UIColor { return WorkfinderColors.primaryColor }
    public static var goodValueActive: UIColor { return WorkfinderColors.greenColorBright }
    public static let warningNormal = UIColor(red: 255, green: 174, blue: 66)
    public static let warningActive = UIColor(red: 63, green: 172, blue: 87)
    public static let badValueNormal = UIColor(red: 255, green: 174, blue: 66)
    public static let badValueActive = UIColor(red: 255, green: 179, blue: 71)
}


