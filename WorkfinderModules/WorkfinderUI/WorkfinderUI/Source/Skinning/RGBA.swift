
import UIKit

public struct RGBA : Codable {
    
    public var red: CGFloat
    public var green: CGFloat
    public var blue: CGFloat
    public var alpha: CGFloat
    
    public static let white: RGBA = RGBA(color: UIColor.white)
    public static let black: RGBA = RGBA(color: UIColor.black)
    public static let red: RGBA = RGBA(color: UIColor.red)
    public static let blue: RGBA = RGBA(color: UIColor.blue)
    public static let green: RGBA = RGBA(color: UIColor.green)
    public static let orange: RGBA = RGBA(color: UIColor.orange)
    public static let yellow: RGBA = RGBA(color: UIColor.yellow)
    public static let clear: RGBA = RGBA(color: UIColor.clear)
    public static let gray: RGBA = RGBA(color: UIColor.gray)
    public static let lightGray: RGBA = RGBA(color: UIColor.lightGray)
    public static let darkGray: RGBA = RGBA(color: UIColor.darkGray)
    public static let workfinderGreen: RGBA = RGBA(color: UIColor(red: 26, green: 168, blue: 76))
    public static let workfinderPurple: RGBA = RGBA(color: UIColor(red: 72, green: 38, blue: 127))
    public static let workfinderPink: RGBA = RGBA(color: UIColor(red:226, green:16, blue: 79))
    public static let workfinderBlue: RGBA = RGBA(color: UIColor(red:20, green:155, blue: 223))
    public static let workfinderAmber: RGBA = RGBA(color: UIColor(red:255, green:198, blue: 44))
    public static let workfinderStagingGold: RGBA = RGBA(color: UIColor(red: 255, green: 212, blue: 76))
    
    public var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    public var alphaForDisabledState: CGFloat = 0.6
    
    public var disabledColor: RGBA {
        return RGBA.lightGray
    }
    
    public var synthesizedDisabledColorByBrightness: RGBA {
        let color = self.uiColor
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if brightness > 0.5 {
            let darkerColor = color.darker(by: 50.0)
            return RGBA(color: darkerColor)
        }
        if brightness < 0.5 {
            let lighterColor = color.lighter(by: 50.0)
            return RGBA(color: lighterColor)
        }
        return self
    }
    
    public var synthesizedDisabledColorBySaturation: RGBA {
        let color = self.uiColor
        let desaturatedColor = color.desaturated(by: 70.0)
        return RGBA(color: desaturatedColor)
    }
    
    public var cgColor: CGColor {
        return uiColor.cgColor
    }
    
    public init() {
        red = 1.0
        green = 1.0
        blue = 1.0
        alpha = 1.0
    }
    
    public init(color: UIColor) {
        red = 0.0
        green = 0.0
        blue = 0.0
        alpha = 0.0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
    
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = max(0, red)
        self.green = max(0,green)
        self.blue = max(0, blue)
        self.alpha = max(0, alpha)
        self.red = min(1.0, red)
        self.green = min(1.0,green)
        self.blue = min(1.0, blue)
        self.alpha = min(1.0, alpha)
    }
    public init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        self.init(
            red: CGFloat(red)/255.0,
            green: CGFloat(green)/255.0,
            blue: CGFloat(blue)/255.0,
            alpha: alpha)
    }
    
    public init(hexString: String) {
        let trimmed = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: trimmed)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = 1.0
    }
}

public extension RGBA {
    func toHexString() -> String {
        let rgb:Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0
        return NSString(format:"#%06x", rgb) as String
    }
}
