//
//  F4SRemoveShortlistItemService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 12/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SRemoveShortlistItemServiceProtocol {
    func removeShortlistItem(completion: @escaping (F4SNetworkResult<F4SUUID>) -> ())
}

public class F4SRemoveShortlistItemService : F4SDataTaskService, F4SRemoveShortlistItemServiceProtocol {
    
    public let shortlistUuid: F4SUUID
    
    public init(shortlistUuid: F4SUUID) {
        self.shortlistUuid = shortlistUuid
        super.init(baseURLString: Config.BASE_URL, apiName: "favourite/\(shortlistUuid)")
    }
    
    public func removeShortlistItem(completion: @escaping (F4SNetworkResult<F4SUUID>) -> ()) {
        let attempting = "Remove company from shortlist"
        super.beginDelete(attempting: attempting) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(_):
                completion(F4SNetworkResult.success(strongSelf.shortlistUuid))
            }
        }
    }
}
