//
//  OfferData.swift
//  WorkfinderApplications
//
//  Created by Keith on 22/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI
import WorkfinderServices

struct OfferTileData: Hashable {
    
    var offerType: OfferType
    var imageUrlString: String?
    var defaultImageText: String?
    var tapAction: ((OfferTileData) -> Void)?
    
    var buttonState: WFButton.State
    private var hostName: String?
    private var companyName: String?
    
    static func == (lhs: OfferTileData, rhs: OfferTileData) -> Bool {
        guard
            lhs.offerType == rhs.offerType,
            lhs.imageUrlString == rhs.imageUrlString
        else { return false }
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(offerType)
        hasher.combine(imageUrlString)
        hasher.combine(defaultImageText)
    }
    
    enum OfferType: Hashable {
        
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
                return "Respond to Invitation"
            case .placement:
                return "Respond to Offer"
            }
        }
    }
    
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
         tapAction: @escaping (OfferTileData) -> Void
    ) {
        self.offerType = offerType
        self.imageUrlString = imageUrlString
        self.defaultImageText = defaultImageText
        self.buttonState = buttonState
        self.hostName = hostName
        self.companyName = companyName
        self.tapAction = tapAction
    }
    
    init(application: Application, tapAction: @escaping (OfferTileData) -> Void ) {
        self.init(
            offerType: .placement(uuid: application.placementUuid),
            imageUrlString: application.logoUrl,
            defaultImageText: application.companyName,
            buttonState: .normal,
            hostName: application.hostName,
            companyName: application.companyName,
            tapAction: tapAction
        )
    }
    
    init(interview: InterviewJson, tapAction: @escaping (OfferTileData) -> Void ) {
        self = OfferTileData(
            offerType: .interview(id: interview.id ?? -1),
            imageUrlString: interview.placement?.association?.host?.photo,
            defaultImageText: interview.placement?.association?.host?.fullname,
            buttonState: .normal,
            hostName: interview.placement?.association?.host?.fullname,
            companyName: interview.placement?.association?.location?.company?.name,
            tapAction: tapAction
        )
    }
}
