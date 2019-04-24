//
//  WEXResult.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 16/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public enum WEXResult<SUCCESSTYPE,FAILURETYPE> {
    case success(SUCCESSTYPE)
    case failure(FAILURETYPE)
}
