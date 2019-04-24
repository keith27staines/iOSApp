import Foundation
import WorkfinderCommon

public class RecommendationCompanyConverter {
    
    public func convert(recommendations: [RecommendationProtocol]) -> [CompanyViewData] {
        var companies = [CompanyViewData]()
        for recommendation in recommendations {
            if let company = companyViewDataFromUuid(recommendation.uuid) {
                companies.append(company)
            }
        }
        return companies
    }
    
    public func convert(companies: [CompanyViewData]) -> [Recommendation] {
        var recommendations = [Recommendation]()
        for (index,company) in companies.enumerated() {
            let recommendaton = Recommendation(companyUUID: company.uuid, sortIndex: index)
            recommendations.append(recommendaton)
        }
        return recommendations
    }
    
    func companyViewDataFromUuid(_ companyUuid: F4SUUID?) -> CompanyViewData? {
        guard let companyUuid = companyUuid,
            let company = DatabaseOperations.sharedInstance.companyWithUUID(companyUuid)
            else { return nil }
        return CompanyViewData(company: company)
    }
}
