
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
    
    static func standardFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        UIFont.init(name: WFTextStyle.helveticaFontRegularName, size: size)?.withWeight(weight) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }

    static var helveticaFontRegularName = "HelveticaNeue-Regular"
    static var helveticaFontBoldName = "HelveticaNeue-Bold"
    
    static var pageTitleColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var pageTitleFont = UIFont(name: helveticaFontBoldName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let pageTitle = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var headlineTitleColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var headlineTitleFont = UIFont(name: helveticaFontBoldName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let headlineTitle = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var sectionTitleColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var sectionTitleFont = UIFont(name: helveticaFontBoldName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let sectionTitle = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var subtitleTitleColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var subtitleTitleFont = UIFont(name: helveticaFontBoldName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let subtitleTitle = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var bodyTextRegularColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var bodyTextRegularFont = UIFont(name: helveticaFontBoldName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let bodyTextRegular = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var bodyTextBoldColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var bodyTextBoldFont = UIFont(name: helveticaFontBoldName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let bodyTextBold = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var labelTextRegularColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var labelTextRegularFont = UIFont(name: helveticaFontBoldName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let labelTextRegular = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var labelTextBoldColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var labelTextBoldFont = UIFont(name: helveticaFontBoldName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let labelTextBold = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var smallLabelTextRegularColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var smallLabelTextRegularFont = UIFont(name: helveticaFontBoldName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let smallLabelTextRegular = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
    
    static var smallLabelTextBoldColor = UIColor(red: 0.126, green: 0.671, blue: 0.282, alpha: 1)
    static var smallLabelTextBoldFont = UIFont(name: helveticaFontBoldName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
    static let smallLabelTextBold = WFTextStyle(font: pageTitleFont, color: pageTitleColor)
}

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
      let newDescriptor = fontDescriptor.addingAttributes([.traits: [
        UIFontDescriptor.TraitKey.weight: weight]
      ])
      return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}

