//
//  ImageService.swift
//  ChiriiEvenimente
//
//  Created by Timea Tivadar on 5/17/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Photos
import KeychainSwift

class ImageService {
    // progress bytes
    var totalBytes: Double = 0.0
    var totalBytesWrite: Double = 0.0
    var countImagesUploading = 0

    let imageUrl = "images"

    class var sharedInstance: ImageService {
        struct Static {
            static let instance: ImageService = ImageService()
        }
        return Static.instance
    }

    func getImage(url: NSURL, completed: @escaping (_ succeeded: Bool, _ image: UIImage?) -> Void) {
        DispatchQueue.main.async {
            guard let path = url.path else {
                completed(false, nil)
                return
            }

            let imageName = path.characters.split { $0 == "/" }.map(String.init)
            let localPath: URL = FileHelper.fileInDocumentsDirectory(filename: imageName.last!)
            if FileHelper.existFileAtPath(path: localPath.path) {
                completed(true, self.getImageAtPath(path: localPath as NSURL))
            } else {
                Alamofire.request(url.absoluteString!, method: .get, headers: [:]).responseData { response in
                    switch response.result {
                    case .failure(let error):
                        log.error(error.localizedDescription)
                        completed(false, nil)

                    case .success:
                        self.saveLocally(localPath: localPath, data: response.data! as NSData)
                        if FileHelper.existFileAtPath(path: localPath.path) {
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

    func getReduceNsData(image: UIImage) -> NSData {
        let originalNsData: NSData = UIImageJPEGRepresentation(image, 1)! as NSData
        let imageSize: Float = Float(originalNsData.length) / 1024 / 1024
        var compressionQuality: CGFloat = 1
        if imageSize > 0 && imageSize < 2 {
            compressionQuality = 0.9
        }
        if imageSize > 2 && imageSize < 4 {
            compressionQuality = 0.7
        }
        if imageSize > 4 && imageSize < 6 {
            compressionQuality = 0.5
        }
        if imageSize > 6 {
            compressionQuality = 0.3
        }
        return UIImageJPEGRepresentation(image, compressionQuality)! as NSData
    }
}

// MARK: - local operations
extension ImageService {
    func saveLocally(localPath: URL, data: NSData) {
        FileHelper.saveData(data: data, path: localPath)
    }

    func deleteLocally(localPath: URL) {
        FileHelper.deleteFile(path: localPath.path)
    }
}
