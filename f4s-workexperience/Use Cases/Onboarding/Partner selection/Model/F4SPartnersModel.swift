//
//  PartnerModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public class F4SPartnersModel {
    
    static func hardCodedPartners() -> [F4SPartner] {
        let parent = F4SPartner(uuid:   "2c4a2c39-eac7-4573-aa14-51c17810e7a1", name: "Parent (includes guardian)")
        let school = F4SPartner(uuid:   "4b2ac792-5e2c-4ee9-b825-93d5d5411b33", name: "My School")
        let friend = F4SPartner(uuid:   "a89feda0-4297-461d-b076-e291498dce9e", name: "My Friend")
        let villiers = F4SPartner(uuid: "9f2a9d9c-1ccb-4a7e-9097-d43b6da8a801", name: "Villiers Park Educational Trust")
        return [parent, school, friend, villiers]
    }
    
    lazy var partnerService: F4SPartnerServiceProtocol = {
        return F4SPartnerService()
    }()
    
    public var showWillProvidePartnerLater: Bool = false {
        didSet {
            if showWillProvidePartnerLater {
                addOrReplacePartner(F4SPartner.partnerProvidedLater)
            } else {
                removePartner(F4SPartner.partnerProvidedLater)
            }
        }
    }
    
    fileprivate var partners: [F4SUUID:F4SPartner]
    fileprivate var partnersArray: [F4SPartner]
    public internal (set) var serversidePartners: [String : F4SPartner]?
    private (set) var isReady: Bool = false
    
    /// Returns the shared instance
    class var sharedInstance: F4SPartnersModel {
        struct Static {
            static let instance: F4SPartnersModel = F4SPartnersModel()
        }
        return Static.instance
    }
    
    public init() {
        partners = [F4SUUID:F4SPartner]()
        partnersArray = []
        getPartners { (_) in
            //
        }
    }
    
    public func getPartners(completed: @escaping (_ success:Bool) -> Void) {
        guard !isReady else {
            completed(true)
            return
        }
        getHardCodedPartners()
        completed(true)
    }
    
    public func partnerByUpdatingUUID(partner: F4SPartner) -> F4SPartner? {
        guard let serverSidePartners = serversidePartners else {
            return nil
        }
        for serverPartner in serverSidePartners.values {
            if partner.name.lowercased() == serverPartner.name.lowercased() {
                return F4SPartner(uuid: serverPartner.uuid,
                               sortingIndex: serverPartner.sortingIndex,
                               name: serverPartner.name,
                               description: serverPartner.description,
                               imageName: serverPartner.imageName)
            }
        }
        return nil
    }
    
    public func getPartnersFromServer(completed: ((F4SNetworkResult<[F4SPartner]>) -> Void)? = nil) {
        partnerService.getPartners { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.serversidePartners = [:]
            switch result {
            case .success(let serverPartners):
                for partner in serverPartners {
                    strongSelf.serversidePartners![partner.name] = partner
                }
                strongSelf.isReady = true
                completed?(result)
            case .error(_):
                completed?(result)
            }
        }
    }
    
    private func getHardCodedPartners() {
        F4SPartnersModel.hardCodedPartners().forEach { (partner) in
            addOrReplacePartner(partner)
        }
        addOrReplacePartner(F4SPartner.partnerProvidedLater)
    }
    
    /// Adds the specified partner to the local model if it exists in the model
    private func addOrReplacePartner(_ partner: F4SPartner) {
        removePartner(partner)
        addPartner(partner)
    }
    
    /// Remove the specified partner from the local model if it exists in the model
    private func removePartner(_ partner: F4SPartner) {
        guard let existingPartner = partners[partner.uuid] else { return }
        partners[existingPartner.uuid] = nil
        let indexPath = indexPathFor(existingPartner)!
        partnersArray.remove(at: indexPath.row)
    }
    
    private func addPartner(_ partner: F4SPartner) {
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
    func partnerForIndexPath(_ indexPath: IndexPath) -> F4SPartner {
        return partnersArray[indexPath.row]
    }
    
    /// Returns the indexpath for the specified partner if the specified partner exists in the model, otherwise returns nil
    func indexPathFor(_ partner: F4SPartner) -> IndexPath? {
        for (row,p) in partnersArray.enumerated() {
            if p.uuid == partner.uuid {
                return IndexPath(row: row, section: 0)
            }
        }
        return nil
    }
    
    /// Returns the partner with the specified id, if such a partner exists.
    func partnerForUuid(_ uuid:F4SUUID) -> F4SPartner? {
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
    public var selectedPartner: F4SPartner? {
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
