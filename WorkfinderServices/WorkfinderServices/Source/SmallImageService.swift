
import Foundation
import UIKit

public protocol SmallImageServiceProtocol {
    func fetchImage(urlString: String?, defaultImage: UIImage?, completion: @escaping (UIImage?) -> Void)
}

public class SmallImageService: SmallImageServiceProtocol {
    
    static var session: URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()
    
    var session: URLSession { SmallImageService.session }
    
    public init() {}
    
    public func fetchImage(urlString: String?, defaultImage: UIImage?, completion: @escaping (UIImage?) -> Void) {
        guard
            let urlString = urlString,
            let url = URL(string: urlString) else {
            completion(defaultImage)
            return
        }
        session.dataTask(with: url) { (data, response, error) in
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
    }
    
}
