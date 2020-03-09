//
//  MapModelManager.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 05/03/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public class MapModelManager {
    
    public enum State {
        case downloading(percentage: Int)
        case parsing
        case mapModelReady(mapModel: MapModel)
        case waiting
    }
    
    public func cancel() {
        
    }
    
    public var mapModel: MapModel?
    
    func getMapModel(completion: () -> WEXResult<MapModelManager, Error>) {
        
    }
    
    public func refreshMapModel(completion: () -> WEXResult<MapModelManager, Error>) {
        
    }
    
    public func promoteStagedFile() {
        
    }

}
