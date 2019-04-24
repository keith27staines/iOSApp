//
//  Company.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 05/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon

public struct CompanyViewData : CompanyViewDataProtocol {
    public var uuid: F4SUUID = ""
    public var appliedState: AppliedState = .notApplied
    public var companyName: String = ""
    public var isRemoved: Bool = false
    public var isFavourited: Bool = false
    public var starRating: Float? = 0
    public var industry: String? = ""
    public var description: String? = ""
    public var revenue: Double? = nil
    public var growth: Double? = nil
    public var employees: Int? = nil
    public var industryIsHidden: Bool { return industry == nil }
    public var duedilUrl: String? = nil
    public var linkedinUrl: String? = nil
    public var postcode: String? = nil
    
    private var company: Company?
    
    init() {}
    
    init(company: Company) {
        self.uuid = company.uuid
        self.company = company
        self.duedilUrl = company.companyUrl
        self.companyName = company.name
        self.growth = company.turnoverGrowth
        self.revenue = company.turnover
        self.employees = Int(company.employeeCount)
        self.description = company.summary
        self.industry = company.industry
        self.starRating = Float(company.rating)
        self.isRemoved = company.isRemoved
        if let placementStatus = company.placement?.status {
            self.appliedState = (placementStatus == .draft) ? .draft : .applied
        } else {
            self.appliedState = .notApplied
        }
    }
}

extension CompanyViewData {
    
    func getLogo(completion: @escaping (UIImage) -> Void) {
        let defaultLogo: UIImage = #imageLiteral(resourceName: "DefaultLogo")
        guard let company = company else {
            completion(defaultLogo)
            return
        }
        company.getLogo(defaultLogo: defaultLogo) { (image) in
            completion(image ?? defaultLogo)
        }
    }
    
    var revenueString: String {
        guard let revenue = revenue, revenue > 0 else { return "" }
        return "Annual revenue: £\(ScaledNumber.formattedString(for: revenue))"
    }
    var growthString: String? {
        guard let growth = growth, growth > 0 else { return "" }
        return "Annual growth: \(Int(100.0*growth))%"
    }
    
    var employeesString: String? {
        guard let employees = employees, employees > 0 else { return "" }
        return "Employees: \(ScaledNumber.formattedString(for: Double(employees)))"
    }
    
    var starRatingIsHidden: Bool {
        guard let rating = starRating else { return true }
        return rating <= 0
    }
    
    var revenueIsHidden: Bool {
        guard let revenue = revenue else { return true }
        return revenue <= 0.0
    }
    
    var growthIsHidden: Bool {
        guard let growth = growth else { return true }
        return growth <= 0.0
    }
    
    var employeesIsHidden: Bool {
        guard let employees = employees else { return true }
        return employees <= 0
    }
    
}
