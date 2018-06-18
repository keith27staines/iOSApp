
import Foundation
import UIKit
import Alamofire

public class F4SImageService {

    public static var sharedInstance = F4SImageService()
    
    let imageUrl = "images"

    func getImage(url: NSURL, completed: @escaping (_ succeeded: Bool, _ image: UIImage?) -> Void) {
        DispatchQueue.main.async {
            guard let path = url.path else {
                completed(false, nil)
                return
            }

            let imageName = path.split { $0 == "/" }.map(String.init)
            let localPath: URL = FileHelper.fileInDocumentsDirectory(filename: imageName.last!)
            if FileHelper.fileExists(path: localPath.path) {
                completed(true, self.getImageAtPath(path: localPath as NSURL))
            } else {
                let url = url as URL
                let session = F4SNetworkSessionManager.shared.interactiveSession
                do {
                    let r = URLRequest(
                    let request = try URLRequest(url: url, method: HTTPMethod.get)
                    let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    })
                    task.resume()
                } catch {
                    
                }
                
                
                Alamofire.request(url.absoluteString!, method: .get, headers: [:]).responseData { response in
                    switch response.result {
                    case .failure(let error):
                        log.error(error.localizedDescription)
                        completed(false, nil)

                    case .success:
                        self.saveLocally(localPath: localPath, data: response.data! as NSData)
                        if FileHelper.fileExists(path: localPath.path) {
                            completed(true, self.getImageAtPath(path: localPath as NSURL))
                        } else {
                            completed(true, UIImage(data: response.data!))
                        }
                    }
                }
            }
        }
    }

    func getImageAtPath(path: NSURL) -> UIImage? {
        guard let path = path.path, let image = UIImage(contentsOfFile: path) else {
            return nil
        }
        return image
    }
}

// MARK: - local operations
extension F4SImageService {
    func saveLocally(localPath: URL, data: NSData) {
        FileHelper.saveData(data: data, path: localPath)
    }
}
