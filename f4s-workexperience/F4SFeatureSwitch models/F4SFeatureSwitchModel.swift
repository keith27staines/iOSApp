//
//  F4SFeatureSwitchModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SFeature : Codable {
    var uuid: F4SUUID
    var name: String?
    var isOn: Bool // mapped from "value"
    
    enum CodingKeys : String, CodingKey {
        case name
        case uuid
        case isOn = "value"
    }
    
}

public protocol F4SFeatureSwitchModelDelegate {
    func featureSwitchModelCompletedFetchFromServer()
}

public enum F4SFeatureSwitchKey : String {
    case emailVerification
    case exampleA
    case exampleB
    case exampleC
    
    public func makefeature() -> F4SFeature {
        switch self {
        case .emailVerification:
            return F4SFeature(uuid: self.rawValue, name: "Email verification", isOn: false)
        case .exampleA:
            return F4SFeature(uuid: self.rawValue, name: "Example A", isOn: false)
        case .exampleB:
            return F4SFeature(uuid: self.rawValue, name: "Example B", isOn: false)
        case .exampleC:
            return F4SFeature(uuid: self.rawValue, name: "Example C", isOn: false)
        }
    }
    
    public static func allKeys() -> [F4SFeatureSwitchKey] {
        return [F4SFeatureSwitchKey.emailVerification,
                F4SFeatureSwitchKey.exampleA,
                F4SFeatureSwitchKey.exampleB,
                F4SFeatureSwitchKey.exampleC]
    }
    
    public static func makeAllFeatures() -> [F4SFeatureSwitchKey:F4SFeature] {
        var features = [F4SFeatureSwitchKey: F4SFeature]()
        for key in F4SFeatureSwitchKey.allKeys() {
            features[key] = key.makefeature()
        }
        return features
    }
}

public class F4SFeatureSwitchModel {
    
    public private (set) var lastFetchFromServer: Date? = nil
    public var lastFetchedFeatures: [F4SFeatureSwitchKey:F4SFeature]? = nil
    
    public private (set) var implementedFeatures: [F4SFeatureSwitchKey:F4SFeature] = F4SFeatureSwitchKey.makeAllFeatures()
    
    private var service: F4SFeatureSwitchServiceProtocol
    private var delegate: F4SFeatureSwitchModelDelegate
    
    public init(delegate: F4SFeatureSwitchModelDelegate, service: F4SFeatureSwitchServiceProtocol?) {
        self.delegate = delegate
        self.service = service ?? F4SFeatureSwitchService()
        getFeaturesFromServer { [weak self] in
            self?.delegate.featureSwitchModelCompletedFetchFromServer()
        }
    }
    
    public func getFeaturesFromServer(completion: (()->())? =  nil) {
        service.getFeatureSwitches { (result) in
            switch result {
            case .success(let features):
                self.updateLastFetchedFeatures(features: features)
            case .error(let error):
                globalLog.debug(error)
            }
            completion?()
        }
    }
    
    func updateLastFetchedFeatures(features: [F4SFeature]) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.lastFetchFromServer = Date()
            var lastFetchedFeatures = [F4SFeatureSwitchKey:F4SFeature]()
            for feature in features {
                if let key = F4SFeatureSwitchKey(rawValue: feature.uuid) {
                    lastFetchedFeatures[key] = feature
                }
            }
            strongSelf.featureSections = [features]
        }
    }
    
    lazy private var featureSections: [[F4SFeature]] = {
        return [Array<F4SFeature>(implementedFeatures.values)]
    }()
    
    public func numberOfSections() -> Int {
        return featureSections.count
    }
    
    public func numberOfFeaturesInSection(section: Int) -> Int {
        return featureSections[section].count
    }
    
    public func feature(indexPath: IndexPath) -> F4SFeature {
        return featureSections[indexPath.section][indexPath.row]
    }
}
