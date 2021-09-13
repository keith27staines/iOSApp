
import Foundation
import WorkfinderServices

public protocol ImageFetching: AnyObject {
    func getImage(url: URL, completion: @escaping ((UIImage?) -> Void))
    func cancel()
}

public class WFSelfLoadingImageView : UIImageView {
    var urlString: String?
    var fetcher: ImageFetching?
    var fetchedImage: UIImage?
    var fetchedUrlString: String?
    var defaultImage: UIImage?
    
    public func load(urlString: String?,
              defaultImage: UIImage?,
              fetcher: ImageFetching = ImageFetcher(),
              completion: ( () -> Void )? = nil ) {
        self.fetcher?.cancel()
        self.fetcher = fetcher
        self.urlString = urlString
        self.defaultImage = defaultImage
        guard
            let urlString = urlString,
            let url = URL(string: urlString)
        else {
            self.image = defaultImage
            completion?()
            return
        }
        if urlString == self.fetchedUrlString {
            if self.fetchedImage != nil {
                image = fetchedImage
                completion?()
                return
            }
        }
        prepareForNewFetch()
        self.fetcher?.getImage(url: url, completion: { [weak self] (image) in
            DispatchQueue.main.async {
                guard let strongSelf = self, urlString == self?.urlString else {
                    completion?()
                    return
                }
                if image != nil {
                    strongSelf.fetchedUrlString = urlString
                    strongSelf.fetchedImage = image
                }
                strongSelf.urlString = urlString
                strongSelf.image = strongSelf.fetchedImage ?? defaultImage
                completion?()
            }
        })
    }
    
    func prepareForNewFetch() {
        self.image = defaultImage
        self.fetchedUrlString = nil
        self.fetchedImage = nil
    }
}

public class ImageFetcher : ImageFetching {
    var cancelled: Bool = false
    public let session = SmallImageService.session
    var dataTask: URLSessionDataTask?
    
    public init() {}
    
    public func getImage(urlString: String?, completion: @escaping ((UIImage?) -> Void)) {
        guard
            let urlString = urlString,
            urlString.isEmpty == false,
            let url = URL(string: urlString)
        else {
            completion(nil)
            return
        }
        getImage(url: url, completion: completion)
    }
    
    /// Attempts to get image data from the specified url. The data retrieved by the get is used to construct a UIImage.
    /// The completion handler is called on the main thread because the image will be used on the main thread
    /// - parameter url: the Url from which to retrieve image data
    /// - parameter completion: Returns the image or nil if there was an error. Always called on the main thread
    public func getImage(url: URL, completion: @escaping ((UIImage?) -> Void)) {
        let url = url as URL
        dataTask = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data,
                let image = UIImage(data: data),
                self?.cancelled == false
            else {
                completion(nil)
                return
            }
            
            completion(image)
        }
        dataTask?.resume()
    }
    
    public func cancel() {
        cancelled = true
        dataTask?.cancel()
    }
}
