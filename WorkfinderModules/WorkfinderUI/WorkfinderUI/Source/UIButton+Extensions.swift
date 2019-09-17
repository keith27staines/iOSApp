
import UIKit

public extension UIButton {
    
    /// Creates a UIImage instance filled with the specified color
    ///
    /// - Parameter color: The fill color
    /// - Returns: the image filled with the specified color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /// Sets the background color of the button by creating an image of the
    /// specified color and assigning the image to the specified control state
    ///
    /// - Parameters:
    ///   - color: The required background color for the specified state
    ///   - state: The button state that will use the specified color
    func setBackgroundColor(color: UIColor, forUIControlState state: UIControl.State) {
        self.setBackgroundImage(imageWithColor(color: color), for: state)
    }
}
