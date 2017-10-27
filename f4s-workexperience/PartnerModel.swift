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
    case ncs
    case parent
    case school
    case friend
    case princesTrust
    case later
}

public struct PartnersModel {
    fileprivate var partners: [PartnerUUID:Partner]
    fileprivate var partnersArray: [Partner]
    
    public init() {
        partners = [PartnerUUID:Partner]()
        partnersArray = [Partner]()
        partnersArray.append(Partner(uuid: .ncs, acronym: "NCS", name: "NCS", description: "National Citizen Service", imageName: "partnerLogoNCS"))
        partnersArray.append(Partner(uuid: .parent, name: "My parent", description: "Your parent or guardian"))
        partnersArray.append(Partner(uuid: .school, name: "My teacher"))
        partnersArray.append(Partner(uuid: .friend, name: "My friend"))
        partnersArray.append(Partner(uuid: .princesTrust, name: "Prince's Trust"))
        partnersArray.append(Partner(uuid: .later, name: "I will do this later"))
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
