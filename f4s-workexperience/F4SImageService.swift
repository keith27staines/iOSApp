
import Foundation
import UIKit

public class F4SImageService {

    public static var sharedInstance = F4SImageService()
    
    let imageUrl = "images"

    func getImage(url: NSURL, completed: @escaping (_ succeeded: Bool, _ image: UIImage?) -> Void) {
        DispatchQueue.main.async {
            guard let path = url.path else {
                completed(false, nil)
                return
            }
            let attempting = "Download image"
            let imageName = path.split { $0 == "/" }.map(String.init)
            let localPath: URL = FileHelper.fileInDocumentsDirectory(filename: imageName.last!)
            if FileHelper.fileExists(path: localPath.path) {
                completed(true, self.getImageAtPath(path: localPath as NSURL))
            } else {
                let url = url as URL
                let session = F4SNetworkSessionManager.shared.interactiveSession
                let request = F4SDataTaskService.urlRequest(verb: .get, url: url, dataToSend: nil)
                let dataTask = F4SDataTaskService.dataTask(with: request, session: session, attempting: attempting, completion: { (result) in
                    
                    switch result {
                        
                    case .error(_):
                        completed(false, nil)
                        
                    case .success(let data):
                        
                        guard let data = data else {
                            _ = F4SNetworkDataErrorType.noData.error(attempting: attempting)
                            completed(false, nil)
                            return
                        }
                        self.saveLocally(localPath: localPath, data: data as NSData)
                        if FileHelper.fileExists(path: localPath.path) {
                            completed(true, self.getImageAtPath(path: localPath as NSURL))
                        } else {
                            completed(true, UIImage(data: data))
                        }
                    }
                })
                dataTask.resume()
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
