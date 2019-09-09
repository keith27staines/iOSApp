//
//  SelfLoadingImageView.swift
//  WorkfinderUI
//
//  Created by Keith Dev on 03/09/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public protocol ImageFetching: class {
    func getImage(url: URL, completion: @escaping ((UIImage?) -> Void))
    func cancel()
}

public class F4SSelfLoadingImageView : UIImageView {
    var urlString: String?
    var fetcher: ImageFetching?
    public func load(urlString: String?,
              defaultImage: UIImage?,
              fetcher: ImageFetching = ImageFetcher(),
              completion: ( () -> Void )? = nil ) {
        self.fetcher?.cancel()
        self.urlString = self.urlString ?? urlString
        self.image = defaultImage
        guard let urlString = urlString, let url = URL(string: urlString) else {
            completion?()
            return
        }
        self.fetcher = fetcher
        self.fetcher?.getImage(url: url, completion: { [weak self] (image) in
            DispatchQueue.main.async {
                guard let strongSelf = self, urlString == self?.urlString else {
                    completion?()
                    return
                }
                strongSelf.image = image ?? defaultImage
                strongSelf.urlString = urlString
                completion?()
            }
        })
    }
}

public class ImageFetcher : ImageFetching {
    var cancelled: Bool = false
    let session = URLSession.init(configuration: URLSessionConfiguration.default)
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
