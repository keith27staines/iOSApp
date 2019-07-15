
import UIKit
import WorkfinderCommon
import WorkfinderNetworking

public class F4SImageService {

    public static var sharedInstance = F4SImageService()

    /// Attempts to get image data from the specified url. The data retrieved by the get is used to construct a UIImage.
    /// The completion handler is called on the main thread because the image will be used on the main thread
    /// - parameter url: the Url from which to retrieve image data
    /// - parameter completion: Returns the image or nil if there was an error. Always called on the main thread
    func getImage(url: NSURL, completion: @escaping (_ image: UIImage?) -> Void) {
        let attempting = "Download image"
        let url = url as URL
        let session = F4SNetworkSessionManager.shared.smallImageSession
        session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    _ = F4SNetworkError(error: error!, attempting: attempting)
                    completion(nil)
                    return
                }
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data,
                    let image = UIImage(data: data)
                    else {
                        completion(nil)
                        return
                }
                completion(image)
            }
        }.resume()
    }
}
