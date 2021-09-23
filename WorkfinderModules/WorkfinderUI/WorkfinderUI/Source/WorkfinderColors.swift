import UIKit

public struct WFColorPalette {
    
    // standard wf colors
    public static var graphicsGreen = UIColor(red: 0.278, green: 0.788, blue: 0.424, alpha: 1)
    public static var readingGreen = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    public static var salmon = UIColor(red: 1, green: 0.396, blue: 0.231, alpha: 1)
    public static var pink = UIColor(red: 1, green: 0.482, blue: 0.694, alpha: 1)
    public static var blue = UIColor(red: 0.267, green: 0.796, blue: 0.918, alpha: 1)
    public static var yellow = UIColor(red: 1, green: 0.878, blue: 0.173, alpha: 1)
    public static var dimmedYellow = UIColor(red: 1, green: 0.878, blue: 0.173, alpha: 1)
    public static var greenTint = UIColor(red: 0.68, green: 0.92, blue: 0.748, alpha: 1)
    
    // black and white
    public static var black = UIColor.black
    public static var white = UIColor.white
    public static var offWhite = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
    public static var offBlack = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
    
    // gray tones
    public static var gray1 = UIColor(red: 0.762, green: 0.792, blue: 0.77, alpha: 1)
    public static var gray2 = UIColor(red: 0.636, green: 0.667, blue: 0.645, alpha: 1)
    public static var gray3 = UIColor(red: 0.37, green: 0.387, blue: 0.375, alpha: 1)
    public static var gray4 = UIColor(red: 0.191, green: 0.204, blue: 0.194, alpha: 1)
    public static var grayLight = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
    public static var border = gray1
}

public struct WFColorGradient {
    
    public var colors: [UIColor]
    
    public static var gradientGreen = WFColorGradient(
        colors: [
            UIColor(red: 0.057, green: 0.743, blue: 0.252, alpha: 1),
            UIColor(red: 0.018, green: 0.524, blue: 0.162, alpha: 1)
        ]
    )
    
    public static var gradientOrange = WFColorGradient(
        colors: [
            UIColor.init(netHex: 0xE66036),
            UIColor.init(netHex: 0xE66036)
        ]
    )
    
    public static var gradientPink = WFColorGradient(
        colors: [
            UIColor.init(netHex: 0xFF549A),
            UIColor.init(netHex: 0xFF7BB1)
        ]
    )
    
    public static var gradientGreenBlue = WFColorGradient(
        colors: [
            UIColor.init(netHex: 0x47C96C),
            UIColor.init(netHex: 0x44CBEA)
        ]
    )
    
    public static var gradientPinkOrangeYellow = WFColorGradient(
        colors: [
            UIColor.init(netHex: 0xF979A9),
            UIColor.init(netHex: 0xEAE6E),
            UIColor.init(netHex: 0xFEDB56)
        ]
    )
    
    public static var gradientBlue = WFColorGradient(
        colors: [
            UIColor.init(netHex: 0x3CB5D1),
            UIColor.init(netHex: 0x44CBEA)
        ]
    )
}

public struct WorkfinderColors {
    public static let primaryColor = WFColorPalette.readingGreen
    public static let greenColorBright = WFColorPalette.greenTint
    public static let greenColorDark = WFColorPalette.graphicsGreen
    
    public static let white = UIColor.white
    public static let black = UIColor.black
    
    public static let highlightBlue = UIColor.blue
    public static let oceanBlue = UIColor(red: 0, green: 200, blue: 255)
    public static let lightGrey = UIColor(white: 0.93, alpha: 1)
    public static let darkGrey = UIColor(white: 0.7, alpha: 1)
    public static let warmGrey = UIColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 1)
    public static let workfinderPurple = UIColor(red: 55, green: 21, blue: 106)
    
    public static var goodValueNormal: UIColor { return WorkfinderColors.primaryColor }
    public static var goodValueActive: UIColor { return WorkfinderColors.greenColorBright }
    public static let warningNormal = UIColor(red: 255, green: 174, blue: 66)
    public static let warningActive = UIColor(red: 63, green: 172, blue: 87)
    public static let badValueNormal = UIColor(red: 255, green: 174, blue: 66)
    public static let badValueActive = UIColor(red: 255, green: 179, blue: 71)
    
    public static let textLight = UIColor.lightGray
    public static let textMedium = UIColor.gray
    public static let textDark = UIColor.darkGray
    
    public static let gray2 = UIColor.init(white: 0.200, alpha: 1)
    public static let gray3 = UIColor.init(white: 0.388, alpha: 1)
    public static let gray4 = UIColor.init(white: 0.663, alpha: 1)
    public static let gray5 = UIColor.init(white: 0.749, alpha: 1)
    public static let gray6 = UIColor.init(white: 0.945, alpha: 1)
}


