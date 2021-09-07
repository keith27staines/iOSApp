
import UIKit

public struct WorkfinderFonts {
    
    public static let largeTitle = UIFont.preferredFont(forTextStyle: .largeTitle)
    public static let title1 = UIFont.preferredFont(forTextStyle: .title1)
    public static let title2 = UIFont.preferredFont(forTextStyle: .title2)
    public static let title3 = UIFont.preferredFont(forTextStyle: .title3)
    public static let heading = UIFont.preferredFont(forTextStyle: .headline)
    public static let subHeading = UIFont.preferredFont(forTextStyle: .subheadline)
    public static let body = UIFont.preferredFont(forTextStyle: .body)
    public static let body2 = UIFont.systemFont(ofSize: 15)
    public static let caption1 = UIFont.preferredFont(forTextStyle: .caption1)
    public static let caption2 = UIFont.preferredFont(forTextStyle: .caption2)
    
    public static func weightedFont(
        for style: UIFont.TextStyle,
        weight: UIFont.Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
}

public struct WFTextStyle {
    var font: UIFont
    var color: UIColor
}

public extension WFTextStyle {
    
    static var helveticaFontBold = "HelveticaNeue-Bold"
    
    static var pageTitleColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var pageTitleFont = UIFont(name: helveticaFontBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let pageTitle = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var headlineTitleColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var headlineTitleFont = UIFont(name: helveticaFontBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let headlineTitle = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var sectionTitleColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var sectionTitleFont = UIFont(name: helveticaFontBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let sectionTitle = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var subtitleTitleColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var subtitleTitleFont = UIFont(name: helveticaFontBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let subtitleTitle = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var bodyTextRegularColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var bodyTextRegularFont = UIFont(name: helveticaFontBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let bodyTextRegular = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var bodyTextBoldColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var bodyTextBoldFont = UIFont(name: helveticaFontBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let bodyTextBold = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var labelTextRegularColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var labelTextRegularFont = UIFont(name: helveticaFontBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let labelTextRegular = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var labelTextBoldColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var labelTextBoldFont = UIFont(name: helveticaFontBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let labelTextBold = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var smallLabelTextRegularColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var smallLabelTextRegularFont = UIFont(name: helveticaFontBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let smallLabelTextRegular = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var smallLabelTextBoldColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var smallLabelTextBoldFont = UIFont(name: helveticaFontBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let smallLabelTextBold = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
}

public struct WFColorPalette {
    static var graphicsGreen = UIColor(red: 0.278, green: 0.788, blue: 0.424, alpha: 1)
    static var readingGreen = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var salmon = UIColor(red: 1, green: 0.396, blue: 0.231, alpha: 1)
    static var pink = UIColor(red: 1, green: 0.482, blue: 0.694, alpha: 1)
    static var blue = UIColor(red: 0.267, green: 0.796, blue: 0.918, alpha: 1)
    static var yellow = UIColor(red: 1, green: 0.878, blue: 0.173, alpha: 1)
    static var dimmedYellow = UIColor(red: 1, green: 0.878, blue: 0.173, alpha: 1)
    static var offBlack = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
    static var offWhitle = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
    static var greenTint = UIColor(red: 0.68, green: 0.92, blue: 0.748, alpha: 1)
    static var gray1 = UIColor(red: 0.762, green: 0.792, blue: 0.77, alpha: 1)
    static var gray2 = UIColor(red: 0.636, green: 0.667, blue: 0.645, alpha: 1)
    static var gray3 = UIColor(red: 0.37, green: 0.387, blue: 0.375, alpha: 1)
    static var gray4 = UIColor(red: 0.191, green: 0.204, blue: 0.194, alpha: 1)
}

struct WFColorGradient {
    
    var colors: [UIColor]
    
    static var gradientGreen = WFColorGradient(
        colors: [
            UIColor(red: 0.057, green: 0.743, blue: 0.252, alpha: 1),
            UIColor(red: 0.018, green: 0.524, blue: 0.162, alpha: 1)
        ]
    )
    
    static var gradientOrange = WFColorGradient(
        colors: [
            UIColor.init(netHex: 0xE66036),
            UIColor.init(netHex: 0xE66036)
        ]
    )
    
    static var gradientPink = WFColorGradient(
        colors: [
            UIColor.init(netHex: 0xFF549A),
            UIColor.init(netHex: 0xFF7BB1)
        ]
    )
    
    static var gradientGreenBlue = WFColorGradient(
        colors: [
            UIColor.init(netHex: 0x47C96C),
            UIColor.init(netHex: 0x44CBEA)
        ]
    )
    
    static var gradientPinkOrangeYellow = WFColorGradient(
        colors: [
            UIColor.init(netHex: 0xF979A9),
            UIColor.init(netHex: 0xEAE6E),
            UIColor.init(netHex: 0xFEDB56)
        ]
    )
    
    static var gradientBlue = WFColorGradient(
        colors: [
            UIColor.init(netHex: 0x3CB5D1),
            UIColor.init(netHex: 0x44CBEA)
        ]
    )
    
}

