
import UIKit

public struct WorkfinderFonts {
    
    public static let largeTitle = UIFont.preferredFont(forTextStyle: .largeTitle)
    public static let title1 = UIFont.preferredFont(forTextStyle: .title1)
    public static let title2 = UIFont.preferredFont(forTextStyle: .title2)
    public static let title3 = UIFont.preferredFont(forTextStyle: .title3)
    public static let heading = UIFont.preferredFont(forTextStyle: .headline)
    public static let subHeading = UIFont.preferredFont(forTextStyle: .subheadline)
    public static let body = UIFont.preferredFont(forTextStyle: .body)
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

