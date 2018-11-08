//
//  DocumentsService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SDocumentServiceProtocol {
    var apiName: String { get }
    var placementUuid: String { get }
    func getDocumentsForPlacement(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ())
    func putDocumentsForPlacement(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkDataResult) -> Void ))
}

public class F4SPlacementDocumentsService : F4SDataTaskService {
    public let placementUuid: String
    
    public init(placementUuid: F4SUUID) {
        self.placementUuid = placementUuid
        let apiName = "placement/\(placementUuid)/documents"
        super.init(baseURLString: Config.BASE_URL, apiName: apiName)
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SPlacementDocumentsService : F4SDocumentServiceProtocol {
    public func getDocumentsForPlacement(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ()) {
        beginGetRequest(attempting: "Get supporting document urls for this placement", completion: completion)
    }
    
    public func putDocumentsForPlacement(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkDataResult) -> Void )) {
        super.beginSendRequest(verb: .put, objectToSend: documents, attempting: "Upload supporting document urls for this placement", completion: completion)
    }
}

//extension F4SPlacementDocumentsService {
//    func postMultipartFormRequest(document: F4SDocument) {
//
//
//        guard let url = URL(string: "https://api.imgur.com/3/image") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let boundary = generateBoundary()
//
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
//        request.httpBody = dataBody
//
//        let session = URLSession.shared
//        session.dataTask(with: request) { (data, response, error) in
//            if let response = response {
//                print(response)
//            }
//
//            if let data = data {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print(json)
//                } catch {
//                    print(error)
//                }
//            }
//            }.resume()
//    }
//
//    func generateBoundary() -> String {
//        return "Boundary-\(NSUUID().uuidString)"
//    }
//
//    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
//
//        let lineBreak = "\r\n"
//        var body = Data()
//
//        if let parameters = params {
//            for (key, value) in parameters {
//                body.append("--\(boundary + lineBreak)")
//                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
//                body.append("\(value + lineBreak)")
//            }
//        }
//
//        if let media = media {
//            for photo in media {
//                body.append("--\(boundary + lineBreak)")
//                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
//                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
//                body.append(photo.data)
//                body.append(lineBreak)
//            }
//        }
//
//        body.append("--\(boundary)--\(lineBreak)")
//
//        return body
//    }
//
//}
//}

