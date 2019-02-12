//
//  Company.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 05/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

enum AppliedState {
    case notApplied
    case draft
    case applied
}

struct CompanyViewData {
    
    var appliedState: AppliedState = .notApplied
    var companyName: String = ""
    var isRemoved: Bool = false
    var isFavourited: Bool = false
    var starRating: Float? = 0
    var industry: String? = ""
    var description: String? = ""
    
    var revenue: Double? = nil
    var growth: Double? = nil
    var employees: Int? = nil
    var industryIsHidden: Bool { return industry == nil }
    var duedilIsHiden: Bool { return duedilUrl == nil }
    var duedilUrl: String? = nil
    
    private var company: Company
    
    init(company: Company) {
        self.company = company
        self.duedilUrl = company.companyUrl
        self.companyName = company.name
        self.growth = company.turnoverGrowth
        self.revenue = company.turnover
        self.employees = Int(company.employeeCount)
        self.description = company.summary
        self.industry = company.industry
        self.starRating = Float(company.rating)
        
        if let placementStatus = company.placement?.status {
            self.appliedState = (placementStatus == .draft) ? .draft : .applied
        } else {
            self.appliedState = .notApplied
        }
    }
    
    func getLogo(completion: @escaping (UIImage) -> Void) {
        let defaultLogo: UIImage = #imageLiteral(resourceName: "DefaultLogo")
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
