
import UIKit

public extension UIImage {
    static func from(
        size: CGSize,
        string: String,
        backgroundColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let fontHeightRatio: CGFloat = 0.8
        let font = UIFont.systemFont(ofSize: fontHeightRatio * size.height, weight: .thin)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .backgroundColor: backgroundColor,
            .paragraphStyle: paragraphStyle
        ]
        UIGraphicsBeginImageContext(rect.size)
        backgroundColor.setFill()
        UIRectFill(rect)
        let text = NSAttributedString(string: string, attributes: attributes)
        text.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
