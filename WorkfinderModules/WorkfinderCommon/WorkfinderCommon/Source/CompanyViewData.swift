import UIKit

public enum AppliedState {
    case notApplied
    case draft
    case applied
}

public protocol CompanyViewDataProtocol {
    var uuid: F4SUUID { get }
    var appliedState: AppliedState { get }
    var companyName: String { get }
    var isAvailableForSearch: Bool { get }
    var isFavourited: Bool { get }
    var starRating: Float? { get }
    var industry: String? { get }
    var description: String? { get }
    var revenue: Double? { get }
    var growth: Double? { get }
    var employees: Int? { get }
    var industryIsHidden: Bool { get }
    var duedilIsHiden: Bool { get }
    var linkedinIsHidden: Bool { get }
    var postcode: String? { get set }
    var duedilUrl: String? { get }
    var linkedinUrl: String? { get }
    var logoUrlString: String? { get }
}

public extension CompanyViewDataProtocol {
    var duedilIsHiden: Bool {
        return duedilUrl == nil || duedilUrl!.isEmpty
    }
    var linkedinIsHidden: Bool {
        return linkedinUrl == nil || linkedinUrl!.isEmpty
    }
}


public struct CompanyViewData : CompanyViewDataProtocol {
    public var uuid: F4SUUID = ""
    public var appliedState: AppliedState = .notApplied
    public var companyName: String = ""
    public var isFavourited: Bool = false
    public var isAvailableForSearch: Bool = false
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
    public var logoUrlString: String?
    
    private var company: Company?
    
    public init() {}
    
    public init(company: Company) {
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
        self.isAvailableForSearch = company.isAvailableForSearch
        self.logoUrlString = company.logoUrl
    }
}

extension CompanyViewData {
        
    public var revenueString: String {
        guard let revenue = revenue, revenue > 0 else { return "" }
        return "£\(ScaledNumber.formattedString(for: revenue))"
    }
    public var growthString: String {
        guard let growth = growth, growth > 0 else { return "" }
        return "\(Int(100.0*growth))%"
    }
    
    public var employeesString: String {
        guard let employees = employees, employees > 0 else { return "" }
        return "\(ScaledNumber.formattedString(for: Double(employees)))"
    }
    
    public var starRatingIsHidden: Bool {
        guard let rating = starRating else { return true }
        return rating <= 0
    }
    
    public var revenueIsHidden: Bool {
        guard let revenue = revenue else { return true }
        return revenue <= 0.0
    }
    
    public var growthIsHidden: Bool {
        guard let growth = growth else { return true }
        return growth <= 0.0
    }
    
    public var employeesIsHidden: Bool {
        guard let employees = employees else { return true }
        return employees <= 0
    }
}
