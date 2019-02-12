//
//  ImageFetcher.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 27/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

protocol ImageFetcherProtocol {
    var defaultImage: UIImage? { get set }
    var source: URL! { get set }
    var session: URLSessionProtocol { get set }
    var response: HTTPURLResponse? { get }
    var error: Error? { get }
    var isFetching: Bool { get }
    func fetch(completion: @escaping (UIImage?) -> () )
    func cancel()
}

protocol URLSessionProtocol {
    var configuration: URLSessionConfiguration { get }
    func makeDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

extension URLSession : URLSessionProtocol {
    func makeDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return dataTask(with: url, completionHandler: completionHandler)
    }
}
extension URLSessionDataTask : URLSessionDataTaskProtocol {}

class ImageFetcher : ImageFetcherProtocol {
    internal private (set) var isFetching: Bool
    var response: HTTPURLResponse?
    var error: Error?
    var defaultImage: UIImage?
    var source: URL!
    var session: URLSessionProtocol
    internal private (set) var dataTask: URLSessionDataTaskProtocol? = nil
    
    init(from source: URL? = nil, session: URLSessionProtocol? = nil, defaultImage: UIImage? = nil) {
        self.session = session ?? URLSession(configuration: URLSessionConfiguration.default)
        self.defaultImage = defaultImage
        self.source = source
        isFetching = false
        error = nil
        response = nil
    }
    
    func fetch(completion:  @escaping (UIImage?) -> () ) {
        cancel()
        isFetching = true
        dataTask = session.makeDataTask(with: source) { (data, response, error) in
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                this.error = error
                this.response = response as? HTTPURLResponse
                guard let data = data, let fetchedImage = UIImage(data: data) else {
                    this.isFetching = false
                    completion(this.defaultImage)
                    return
                }
                this.isFetching = false
                completion(fetchedImage)
            }
        }
        dataTask!.resume()
    }
    
    func cancel() {
        isFetching = false
        dataTask?.cancel()

    }
}
