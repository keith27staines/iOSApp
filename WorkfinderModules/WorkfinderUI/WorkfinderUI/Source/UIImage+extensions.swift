import Foundation

public extension UIImage {
    
    /// returns an image scaled to the specified size
    ///
    /// - parameter size: The size to scale the image to (not preserving aspect ratio)
    func scaledImage(with size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    /// Returns the largest image scaled to fit within the specified size but preserving the original apsect ratio
    ///
    /// - parameter size: The size to fit the image to
    func aspectFitToSize(_ size: CGSize) -> UIImage {
        let aspect = self.size.width / self.size.height
        if size.width / aspect <= size.height {
            return scaledImage(with: CGSize(width: size.width, height: size.width / aspect))
        } else {
            return scaledImage(with: CGSize(width: size.height * aspect, height: size.height))
        }
    }
    
    /// Returns a compressed image not exceeding the specifed size in MB
    ///
    /// - parameter requiredSize: The maximum size of the compressed image
    func compressTo(_ requiredSize: Double) -> UIImage {
        let requiredSizeInBytes = Int(requiredSize * 1024 * 1024)
        var needsMoreCompression: Bool = true
        var quality: CGFloat = 1.0
        var data = self.jpegData(compressionQuality: quality)!
        while (needsMoreCompression && quality > 0.1) {
            
            if data.count <= requiredSizeInBytes {
                needsMoreCompression = false
            } else {
                quality -= 0.1
                data = self.jpegData(compressionQuality: quality)!
            }
        }
        return UIImage(data: data)!
    }
}
