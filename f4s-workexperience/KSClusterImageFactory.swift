
import Foundation
import UIKit
import WorkfinderUI
import CoreGraphics

class KSClusterImageFactory {
    
    var color: UIColor = WorkfinderColors.workfinderPurple
    
    convenience init(color: UIColor) {
        self.init()
        self.color = color
    }
    
    lazy var pinImage: UIImage! = {
        UIImage(named: "markerIcon")?.tinted(with: self.color)
    }()

    func clusterImageForCount(_ count: Int) -> UIImage! {
        guard count > 1 else { return pinImage }

        let font = UIFont.boldSystemFont(ofSize: 17)
        let text = String(count)
        let attributedString = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ])
        let textSize = attributedString.size()
        let rect = CGRect(x: 0, y: 0, width: 60, height: 60)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        ctx?.setFillColor(color.cgColor)
        ctx?.fillEllipse(in: rect)
        ctx?.restoreGState()
        let textRect = rect.insetBy(dx: (rect.size.width - textSize.width) / 2,
                                    dy: (rect.size.height - textSize.height) / 2)
        attributedString.draw(in: textRect)
        let clusterIcon = UIGraphicsGetImageFromCurrentImageContext()
        return clusterIcon
    }
    

}

extension UIImage {
    func tinted(with color: UIColor, isOpaque: Bool = false) -> UIImage? {
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            color.set()
            withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
    }
}