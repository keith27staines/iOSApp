//
//  PartnerModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

public class PartnersModel {
    
    let ncsUID = "15e5a0a6-02cc-4e98-8edb-c3bfc0cb8b7d"
    
    public var showWillProvidePartnerLater: Bool = false {
        didSet {
            if showWillProvidePartnerLater {
                addOrReplacePartner(Partner.partnerProvidedLater)
            } else {
                removePartner(Partner.partnerProvidedLater)
            }
        }
    }
    fileprivate var partners: [F4SUUID:Partner]
    fileprivate var partnersArray: [Partner]
    private (set) var isReady: Bool = false
    
    /// Returns the shared instance
    class var sharedInstance: PartnersModel {
        struct Static {
            static let instance: PartnersModel = PartnersModel()
        }
        
        return Static.instance
    }
    
    public init() {
        partners = [F4SUUID:Partner]()
        partnersArray = []
    }
    
    public func getPartners(completed: @escaping (_ success:Bool) -> Void) {
        guard !isReady else {
            completed(true)
            return
        }
        getHardCodedPartners()
        completed(true)
//        PartnerService.sharedInstance.getAllPartners { [weak self] (success, partnerResult) in
//            guard let strongSelf = self else { return }
//            switch partnerResult {
//            case .value(let boxedPartners):
//                let unboxedPartners = boxedPartners.value
//                for partner in unboxedPartners {
//                    strongSelf.addOrReplacePartner(partner)
//                }
//                strongSelf.isReady = true
//            case .error:
//                completed(false)
//            case .deffinedError:
//                completed(false)
//            }
//        }
    }
    
    private func getHardCodedPartners() {
        var ncsPartner = Partner(uuid: ncsUID, name: "National Citizen Service")
        ncsPartner.imageName = "partnerLogoNCS"
        var nominetPartner = Partner(uuid: "-1", name: "Nominet Trust")
        nominetPartner.imageName = "partnerLogoNominet"
        addOrReplacePartner(ncsPartner)
        addOrReplacePartner(nominetPartner)
        addOrReplacePartner(Partner(uuid: "2c4a2c39-eac7-4573-aa14-51c17810e7a1", name: "Parent (includes guardian)"))
        addOrReplacePartner(Partner(uuid: "96638617-13df-489e-bb10-e02a3dc3391b", name: "My School"))
        addOrReplacePartner(Partner(uuid: "1c72eb94-538c-4a39-b0db-20a9f8269d35", name: "My Friend"))
        addOrReplacePartner(Partner.partnerProvidedLater)
    }
    
    /// Adds the specified partner to the local model if it exists in the model
    private func addOrReplacePartner(_ partner: Partner) {
        removePartner(partner)
        addPartner(partner)
    }
    
    /// Remove the specified partner from the local model if it exists in the model
    private func removePartner(_ partner: Partner) {
        guard let existingPartner = partners[partner.uuid] else { return }
        partners[existingPartner.uuid] = nil
        let indexPath = indexPathFor(existingPartner)!
        partnersArray.remove(at: indexPath.row)
    }
    
    private func addPartner(_ partner: Partner) {
        partners[partner.uuid] = partner
        partnersArray.append(partner)
        partnersArray.sort { (p1, p2) -> Bool in
            if p1.sortingIndex < p2.sortingIndex { return true }
            if p1.sortingIndex > p2.sortingIndex { return false }
            return p1.name.lowercased() <= p2.name.lowercased()
        }
    }
    
    /// Returns the number of sections
    func numberOfSections() -> Int {
        return 1
    }
    
    /// Returns the number of partners in the specified section
    func numberOfRowsInSection(_ section: Int) -> Int {
        return partners.count
    }
    
    /// Returns the parter with the specified index path
    func partnerForIndexPath(_ indexPath: IndexPath) -> Partner {
        return partnersArray[indexPath.row]
    }
    
    /// Returns the indexpath for the specified partner if the specified partner exists in the model, otherwise returns nil
    func indexPathFor(_ partner: Partner) -> IndexPath? {
        for (row,p) in partnersArray.enumerated() {
            if p.uuid == partner.uuid {
                return IndexPath(row: row, section: 0)
            }
        }
        return nil
    }
    
    /// Returns the partner with the specified id, if such a partner exists.
    func partnerForUuid(_ uuid:F4SUUID) -> Partner? {
        return self.partners[uuid]
    }
    
    /// Tests whether the user has selected a partner
    var hasSelectedPartner: Bool {
        return selectedPartnerUUID == nil ? false : true
    }
    
    /// Returns the uuid of the selected partner
    var selectedPartnerUUID: F4SUUID? {
        let key = UserDefaultsKeys.partnerID
        return UserDefaults.standard.object(forKey: key) as? F4SUUID
    }
    
    /// Gets and sets the currently selected partner
    public var selectedPartner: Partner? {
        get {
            guard let selectedPartnerUUID = selectedPartnerUUID else { return nil }
            return partnerForUuid(selectedPartnerUUID)
        }
        set {
            guard let partner = newValue else {
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.partnerID)
                return
            }
            UserDefaults.standard.set(partner.uuid, forKey: UserDefaultsKeys.partnerID)
        }
    }
}
