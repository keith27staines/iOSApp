//
//  PartnerModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

public class PartnersModel {
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
        partnersArray = [Partner.partnerProvidedLater]
    }
    
    public func getPartners(completed: @escaping (_ success:Bool) -> Void) {
        guard !isReady else {
            completed(true)
            return
        }
        PartnerService.sharedInstance.getAllPartners { [weak self] (success, partnerResult) in
            guard let strongSelf = self else { return }
            switch partnerResult {
            case .value(let boxedPartners):
                let unboxedPartners = boxedPartners.value
                for partner in unboxedPartners {
                    strongSelf.addOrReplacePartner(partner)
                }
                strongSelf.isReady = true
            case .error:
                completed(false)
            case .deffinedError:
                completed(false)
            }
        }
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
        for partner in partnersArray {
            if partner.uuid == uuid {
                return partner
            }
        }
        return nil
    }
    
    /// Gets and sets the currently selected partner
    public var selectedPartner: Partner? {
        get {
            let key = UserDefaultsKeys.partnerID
            if let id = UserDefaults.standard.object(forKey: key) as? Int {
                return partnersArray[id]
            } else {
                return nil
            }
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
