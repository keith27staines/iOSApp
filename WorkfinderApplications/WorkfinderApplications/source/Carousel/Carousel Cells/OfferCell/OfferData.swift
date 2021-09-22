//
//  OfferData.swift
//  WorkfinderApplications
//
//  Created by Keith on 22/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

struct OfferData {
    
    enum OfferType {
        
        case interview(id: Int)
        case placement(uuid: String)
        
        var prize: String {
            switch self {
            case .interview: return " has invited you to an interview"
            case .placement: return " has offered you a placement"
            }
        }
        
        var actionButtonText: String {
            switch self {
            case .interview:
                return "Respond to Offer"
            case .placement:
                return "Respond to Invitation"
            }
        }
    }
    
    var offerType: OfferType
    var imageUrlString: String?
    var defaultImageText: String?
    var tapAction: ((OfferData) -> Void)?
    
    var buttonState: WFButton.State
    private var hostName: String?
    private var companyName: String?
    
    var buttonText: String { offerType.actionButtonText }
    
    var text: String? {
        let host = hostName ?? ""
        let company = companyName ?? ""
        if host.isEmpty && company.isEmpty {
            return "This company has \(offerType.prize)"
        }
        if host.isEmpty {
            return "\(company) \(offerType.prize)"
        }
        if company.isEmpty {
            return "\(host) \(offerType.prize)"
        }
        return "\(host) at \(company) \(offerType.prize)"
    }

    init(offerType: OfferType,
         imageUrlString: String?,
         defaultImageText: String?,
         buttonState: WFButton.State = .normal,
         hostName: String?,
         companyName: String?,
         tapAction: @escaping (OfferData) -> Void
    ) {
        self.offerType = offerType
        self.imageUrlString = imageUrlString
        self.defaultImageText = defaultImageText
        self.buttonState = buttonState
        self.hostName = hostName
        self.companyName = companyName
        self.tapAction = tapAction
    }
}
