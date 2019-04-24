//
//  F4STemplateServiceProtocol.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 26/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4STemplateServiceProtocol {
    func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void)
}
