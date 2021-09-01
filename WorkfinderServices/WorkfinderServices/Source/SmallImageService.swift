
import Foundation
import UIKit

public protocol SmallImageServiceProtocol {
    func fetchImage(urlString: String?, defaultImage: UIImage?, completion: @escaping (UIImage?) -> Void)
}

public class SmallImageService: SmallImageServiceProtocol {
    
    public static var session: URLSession = {
        var config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        let session = URLSession(configuration: config)
        return session
    }()
    
    var session: URLSession { SmallImageService.session }
    var task: URLSessionTask?
    
    public init() {}
    public var urlString: String?
    public func fetchImage(urlString: String?, defaultImage: UIImage?, completion: @escaping (UIImage?) -> Void) {
        task?.cancel()
        guard
            let urlString = urlString,
            let url = URL(string: urlString) else {
            completion(defaultImage)
            return
        }
        self.urlString = urlString
        task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                            guard
                    let data = data,
                    let image = UIImage(data: data)
                    else {
                        completion(defaultImage)
                        return
                }
                completion(image)
            }
        }
        task?.resume()
    }
}
