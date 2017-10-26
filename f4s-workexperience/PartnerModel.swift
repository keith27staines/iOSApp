//
//  PartnerModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation
public enum PartnerUUID: F4SUUID {
    public typealias RawValue = String
    case parent
    case teacher
    case other
    case none
    case ncs
}

public struct PartnersModel {
    fileprivate var partners: [PartnerUUID:Partner]
    fileprivate var partnersArray: [Partner]
    
    public init() {
        partners = [PartnerUUID:Partner]()
        partnersArray = [Partner]()
        partnersArray.append(Partner(uuid: .parent, name: "Parent or guardian"))
        partnersArray.append(Partner(uuid: .teacher, name: "Teacher"))
        partnersArray.append(Partner(uuid: .other, name: "Other"))
        partnersArray.append(Partner(uuid: .none, name: "None"))
        partnersArray.append(Partner(uuid: .ncs, name: "National Citizen Service", acronym: "NCS"))
        for partner in self.partnersArray {
            addPartner(partner)
        }
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return partners.count
    }
    
    func partnerForIndexPath(_ indexPath: IndexPath) -> Partner {
        return partnersArray[indexPath.row]
    }
    
    mutating func addPartner(_ partner: Partner) {
        partners[partner.uuid] = partner
    }
    
    public static var partnerUuid: PartnerUUID? {
        get {
            return nil
        }
        set {
            
        }
    }
}
