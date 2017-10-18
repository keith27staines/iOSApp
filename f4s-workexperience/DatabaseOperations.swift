//
//  DatabaseOperations.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/15/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import SQLite

/// Downloaded database operations handler
class DatabaseOperations {
    
    /// Shared instance of the DatabaseOperations class
    class var sharedInstance: DatabaseOperations {
        struct Static {
            static let instance: DatabaseOperations = DatabaseOperations()
        }
        return Static.instance
    }

    init() {
        self.loadConnection()
    }

    /// Reload database connection
    func reloadConection() {
        self.loadConnection()
    }
    
    var isConnected: Bool {
        return _database == nil ? false : true
    }

    fileprivate var database: Connection? {
        if _database == nil {
            loadConnection()
        }
        return _database
    }
    fileprivate var _database: Connection?
    
    fileprivate struct BusinessesCompany {
        static let tableName = "businesses_company"
        static let id: Expression<Int64?> = Expression<Int64?>(BusinessesCompany.idColumnName)
        static let created: Expression<String?> = Expression<String?>(BusinessesCompany.createdColumnName)
        static let modified: Expression<String?> = Expression<String?>(BusinessesCompany.modifiedColumnName)
        static let isRemoved: Expression<Bool?> = Expression<Bool?>(BusinessesCompany.isRemovedColumnName)
        static let uuid: Expression<String?> = Expression<String?>(BusinessesCompany.uuidColumnName)
        static let name: Expression<String?> = Expression<String?>(BusinessesCompany.nameColumnName)
        static let logoUrl: Expression<String?> = Expression<String?>(BusinessesCompany.logoUrlColumnName)
        static let industry: Expression<String?> = Expression<String?>(BusinessesCompany.industryColumnName)
        static let latitude: Expression<Double?> = Expression<Double?>(BusinessesCompany.latitudeColumnName)
        static let longitude: Expression<Double?> = Expression<Double?>(BusinessesCompany.longitudeColumnName)
        static let summary: Expression<String?> = Expression<String?>(BusinessesCompany.summaryColumnName)
        static let employeeCount: Expression<Int64?> = Expression<Int64?>(BusinessesCompany.employeeCountColumnName)
        static let turnover: Expression<Double?> = Expression<Double?>(BusinessesCompany.turnoverColumnName)
        static let turnoverGrowth: Expression<Double?> = Expression<Double?>(BusinessesCompany.turnoverGrowthColumnName)
        static let rating: Expression<Double?> = Expression<Double?>(BusinessesCompany.ratingColumnName)
        static let ratingCount: Expression<Double?> = Expression<Double?>(BusinessesCompany.ratingCountColumnName)
        static let sourceId: Expression<String?> = Expression<String?>(BusinessesCompany.sourceIdColumnName)
        static let hashtag: Expression<String?> = Expression<String?>(BusinessesCompany.hashtagColumnName)
        static let companyUrl: Expression<String?> = Expression<String?>(BusinessesCompany.companyUrlColumnName)

        static let idColumnName: String = "id"
        static let createdColumnName: String = "created"
        static let modifiedColumnName: String = "modified"
        static let isRemovedColumnName: String = "is_removed"
        static let uuidColumnName: String = "uuid"
        static let nameColumnName: String = "name"
        static let logoUrlColumnName: String = "logo_url"
        static let industryColumnName: String = "industry"
        static let latitudeColumnName: String = "latitude"
        static let longitudeColumnName: String = "longitude"
        static let summaryColumnName: String = "summary"
        static let employeeCountColumnName: String = "employee_count"
        static let turnoverColumnName: String = "turnover"
        static let turnoverGrowthColumnName: String = "turnover_growth"
        static let ratingColumnName: String = "rating"
        static let ratingCountColumnName: String = "rating_count"
        static let sourceIdColumnName: String = "source_id"
        static let hashtagColumnName: String = "hashtag"
        static let companyUrlColumnName: String = "webview_url"
    }

    // Row definition for business company interests table
    fileprivate struct BusinessesCompanyInterestRD {
        static let tableName = "businesses_company_interests"
        static let id: Expression<Int64?> = Expression<Int64?>(BusinessesCompanyInterestRD.idColumnName)
        static let businessId: Expression<Int64?> = Expression<Int64?>(BusinessesCompanyInterestRD.businessIdColumnName)
        static let interestId: Expression<Int64?> = Expression<Int64?>(BusinessesCompanyInterestRD.interestIdColumnName)
        static let idColumnName: String = "id"
        static let businessIdColumnName: String = "business_id"
        static let interestIdColumnName: String = "interest_id"
    }
    
    fileprivate struct BusinessesInterest {
        static let tableName = "businesses_interest"
        static let id: Expression<Int64?> = Expression<Int64?>(BusinessesInterest.idColumnName)
        static let created: Expression<String?> = Expression<String?>(BusinessesInterest.createdColumnName)
        static let modified: Expression<String?> = Expression<String?>(BusinessesInterest.modifiedColumnName)
        static let isRemoved: Expression<Bool?> = Expression<Bool?>(BusinessesInterest.isRemovedColumnName)
        static let uuid: Expression<String?> = Expression<String?>(BusinessesInterest.uuidColumnName)
        static let name: Expression<String?> = Expression<String?>(BusinessesInterest.nameColumnName)
        static let interestCount: Expression<Int64?> = Expression<Int64?>(BusinessesInterest.interestCountColumnName)

        static let idColumnName: String = "id"
        static let createdColumnName: String = "created"
        static let modifiedColumnName: String = "modified"
        static let isRemovedColumnName: String = "is_removed"
        static let uuidColumnName: String = "uuid"
        static let nameColumnName: String = "name"
        static let interestCountColumnName: String = "interest_count"
    }

    fileprivate struct BusinessesSocialShareTemplate {
        static let tableName = "businesses_socialsharetemplate"
        static let id: Expression<Int64?> = Expression<Int64?>(BusinessesSocialShareTemplate.idColumnName)
        static let created: Expression<String?> = Expression<String?>(BusinessesSocialShareTemplate.createdColumnName)
        static let modified: Expression<String?> = Expression<String?>(BusinessesSocialShareTemplate.modifiedColumnName)
        static let isRemoved: Expression<Bool?> = Expression<Bool?>(BusinessesSocialShareTemplate.isRemovedColumnName)
        static let uuid: Expression<String?> = Expression<String?>(BusinessesSocialShareTemplate.uuidColumnName)
        static let type: Expression<String?> = Expression<String?>(BusinessesSocialShareTemplate.typeColumnName)
        static let text: Expression<String?> = Expression<String?>(BusinessesSocialShareTemplate.textColumnName)
        static let subjectLine: Expression<String?> = Expression<String?>(BusinessesSocialShareTemplate.subjectLineColumnName)

        static let idColumnName: String = "id"
        static let createdColumnName: String = "created"
        static let modifiedColumnName: String = "modified"
        static let isRemovedColumnName: String = "is_removed"
        static let uuidColumnName: String = "uuid"
        static let typeColumnName: String = "type"
        static let textColumnName: String = "text"
        static let subjectLineColumnName: String = "subject_line"
    }
}

extension DatabaseOperations {
    /// Get all companies from the company database
    public func getAllCompanies( completed: @escaping (_ companies: [Company]) -> Void) {
        guard let db = database else {
            log.debug("`getAllCompanies` failed because the database connection is nil")
            completed([])
            return
        }
        do {
            var companyList: [Company] = []
            let selectStatement: String = "SELECT id, uuid, latitude, longitude FROM businesses_company WHERE latitude NOTNULL AND longitude NOTNULL"
            
            let stmt = try db.prepare(selectStatement)
            
            for row in stmt {
                let comp = DatabaseOperations.sharedInstance.getCompanyFromRowAndStatement(row: row, statement: stmt)
                companyList.append(comp)
            }
            completed(companyList)
            return
        } catch {
            let nsError = error as NSError
            log.debug(nsError.localizedDescription)
            completed([])
        }
    }
    
    /// Transform row from database in Company object
    ///
    /// - Parameters:
    ///   - row: row from database
    ///   - statement: statement of the database
    /// - Returns: Company object from row
    fileprivate func getCompanyFromRowAndStatement(row: Statement.Element, statement: Statement) -> Company {
        var company = Company()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        for (index, name) in statement.columnNames.enumerated() {
            if index < row.count, let value = row[index] {
                if name == BusinessesCompany.idColumnName, let id = value as? Int64 {
                    company.id = id
                }
                if name == BusinessesCompany.createdColumnName, let createDateValue = value as? String, let createdDate = formatter.date(from: createDateValue) {
                    company.created = createdDate
                }
                if name == BusinessesCompany.modifiedColumnName, let modifiedDateValue = value as? String, let modifiedDate = formatter.date(from: modifiedDateValue) {
                    company.modified = modifiedDate
                }
                if name == BusinessesCompany.isRemovedColumnName, let isRemoved = value as? Bool {
                    company.isRemoved = isRemoved
                }
                if name == BusinessesCompany.uuidColumnName, let uuid = value as? String {
                    company.uuid = uuid
                }
                if name == BusinessesCompany.nameColumnName, let name = value as? String {
                    company.name = name
                }
                if name == BusinessesCompany.logoUrlColumnName, let logoUrl = value as? String {
                    company.logoUrl = logoUrl
                }
                if name == BusinessesCompany.industryColumnName, let industry = value as? String {
                    company.industry = industry
                }
                if name == BusinessesCompany.latitudeColumnName, let latitude = value as? Double {
                    company.latitude = latitude
                }
                if name == BusinessesCompany.longitudeColumnName, let longitude = value as? Double {
                    company.longitude = longitude
                }
                if name == BusinessesCompany.summaryColumnName, let summary = value as? String {
                    company.summary = summary
                }
                if name == BusinessesCompany.employeeCountColumnName, let employeeCount = value as? Int64 {
                    company.employeeCount = employeeCount
                }
                if name == BusinessesCompany.turnoverColumnName, let turnover = value as? Double {
                    company.turnover = turnover
                }
                if name == BusinessesCompany.turnoverGrowthColumnName, let turnoverGrowth = value as? Double {
                    company.turnoverGrowth = turnoverGrowth
                }
                if name == BusinessesCompany.ratingColumnName, let rating = value as? Double {
                    company.rating = rating
                }
                if name == BusinessesCompany.ratingCountColumnName, let ratingCount = value as? Double {
                    company.ratingCount = ratingCount
                }
                if name == BusinessesCompany.sourceIdColumnName, let sourceId = value as? String {
                    company.sourceId = sourceId
                }
                if name == BusinessesCompany.hashtagColumnName, let hashtag = value as? String {
                    company.hashtag = hashtag
                }
                if name == BusinessesCompany.companyUrlColumnName, let companyUrl = value as? String {
                    company.companyUrl = companyUrl
                }
            }
        }
        return company
    }

    
    /// Get all interests from the database as a dictionary keyed by id
    public func getAllInterests( completed: @escaping (_ interests: [Int64:Interest]) -> Void) {
        guard let db = database else {
            log.debug("`getAllInterests` failed because the database connection is nil")
            completed([:])
            return
        }
        do {
            var allInterests: [Int64:Interest] = [:]
            let selectStatement: String = "SELECT id, uuid, name FROM businesses_interest"
            let stmt = try db.prepare(selectStatement)
            
            for row in stmt {
                let interest = DatabaseOperations.sharedInstance.getInterestFromRowAndStatement(row: row, statement: stmt)
                allInterests[interest.id] = interest
            }
            completed(allInterests)
            return
        } catch {
            let nsError = error as NSError
            log.debug(nsError.localizedDescription)
            completed([:])
        }
    }

    /// Return interest Ids for the specified company
    ///
    /// - Parameters:
    ///   - companyId: The company for which interests are required
    ///   - returns: list of ids of interests of the company
    public func interestIdsFor(companyId: Int64) -> [Int64] {
        guard let db = database else {
            log.debug("Can't get interests for company because the database isn't loaded")
            return []
        }
   
        var interestIdList: [Int64] = []
        let selectInterestsInLocation: String = "SELECT interest_id FROM businesses_company_interests WHERE company_id == \(companyId)"
        guard let stmt = try? db.prepare(selectInterestsInLocation) else {
            return []
        }
        
        for row in stmt {
            let businessCompanyInterest = DatabaseOperations.sharedInstance.getBusinessesCompanyInterestFromRowAndStatement(row: row, statement: stmt)
            interestIdList.append(businessCompanyInterest.interestId)
        }
        return interestIdList
    }
    
    /// Returns the company with the specified uuid
    public func companyWithId(_ id: Int64) -> Company? {
        guard let db = database else {
            log.debug("Can't find company with specified uuid because the database isn't loaded")
            return nil
        }
//        let selectString: String = "SELECT * FROM businesses_company WHERE id = '\(id)'"
        let selectString: String = "SELECT * FROM businesses_company WHERE id = \(id)"
        guard let stmt = try? db.prepare(selectString) else {
            // Company just wasn't found
            return nil
        }
        
        for row in stmt {
            let company = DatabaseOperations.sharedInstance.getCompanyFromRowAndStatement(row: row, statement: stmt)
            return company
        }
        return nil
    }

    /// Get companies with the uuid specified
    ///
    /// - Parameters:
    ///   - withUuid: uuid of the company
    ///   - completed: return list of companies with that list
    public func getCompanies(withUuid: [String], completed: @escaping (_ companies: [Company]) -> Void) {
        guard let db = database else {
            log.debug("Can't load database")
            completed([])
            return
        }
        do {
            var companyList: [Company] = []

            let uuidsString = withUuid.flatMap({ $0.replacingOccurrences(of: "-", with: "") }).joined(separator: "\",\"")

            let selectCompaniesWithUuid: String = "SELECT * FROM businesses_company WHERE uuid IN (\"\(uuidsString)\")"

            let stmt = try db.prepare(selectCompaniesWithUuid)

            for row in stmt {
                let comp = DatabaseOperations.sharedInstance.getCompanyFromRowAndStatement(row: row, statement: stmt)
                companyList.append(comp)
            }
            completed(companyList)
            return
        } catch {
            let nsError = error as NSError
            log.debug(nsError.localizedDescription)
            completed([])
        }
    }

    /// Get template of the social share for type
    ///
    /// - Parameter type: social share type
    /// - Returns: template string
    public func getBusinessesSocialShareTemplateOfType(type: SocialShare) -> String {
        guard let db = database else {
            log.debug("Can't load database")
            return ""
        }
        do {
            let selectShareTemplateOfType: String = "SELECT * from businesses_socialsharetemplate where type = '\(type.rawValue)'"

            let stmt = try db.prepare(selectShareTemplateOfType)

            for row in stmt {
                let text = getShareTemplateFromRowAndStatement(row: row, statement: stmt)
                return text
            }
        } catch {
            let nsError = error as NSError
            log.debug(nsError.localizedDescription)
        }
        return ""
    }

    /// Get subject of the social share for type
    ///
    /// - Parameter type: social share type
    /// - Returns: subject to share
    public func getBusinessesSocialShareSubjectTemplateOfType(type: SocialShare) -> String {
        guard let db = database else {
            log.debug("Can't load database")
            return ""
        }
        do {
            let selectShareTemplateOfType: String = "SELECT * from businesses_socialsharetemplate where type = '\(type.rawValue)'"

            let stmt = try db.prepare(selectShareTemplateOfType)

            for row in stmt {
                let text = getShareSubjectTemplateFromRowAndStatement(row: row, statement: stmt)
                return text
            }
        } catch {
            let nsError = error as NSError
            log.debug(nsError.localizedDescription)
        }
        return ""
    }

    /// Transforms row in Interest object
    ///
    /// - Parameter row: row from database
    /// - Returns: Interest object
    private func getInterestFromRow(row: Row) -> Interest {
        var interest = Interest()

        if let id = row[BusinessesInterest.id] {
            interest.id = id
        }

        if let uuid = row[BusinessesInterest.uuid] {
            interest.uuid = uuid
        }
        if let name = row[BusinessesInterest.name] {
            interest.name = name
        }
        return interest
    }
    
    private func getBusinessesCompanyInterestFromRowAndStatement(
        row: Statement.Element,
        statement: Statement) -> BusinessCompanyInterest {
        var businessCompanyInterest = BusinessCompanyInterest()
        for (index, name) in statement.columnNames.enumerated() {
            if index < row.count, let value = row[index] {
                if name == BusinessesCompanyInterestRD.idColumnName, let id = value as? Int64 {
                    businessCompanyInterest.id = id
                }
                if name == BusinessesCompanyInterestRD.businessIdColumnName, let companyId = value as? Int64 {
                    businessCompanyInterest.companyId = companyId
                }
                if name == BusinessesCompanyInterestRD.interestIdColumnName, let interestId = value as? Int64 {
                    businessCompanyInterest.interestId = interestId
                }
            }
        }
        return businessCompanyInterest
    }

    /// Transforms row and statment in Interest object
    ///
    /// - Parameters:
    ///   - row: row from database
    ///   - statement: statement from databse
    /// - Returns: Interest object
    private func getInterestFromRowAndStatement(row: Statement.Element, statement: Statement) -> Interest {
        var interest = Interest()
        for (index, name) in statement.columnNames.enumerated() {
            if index < row.count, let value = row[index] {
                if name == BusinessesInterest.idColumnName, let id = value as? Int64 {
                    interest.id = id
                }
                if name == BusinessesInterest.uuidColumnName, let uuid = value as? String {
                    interest.uuid = uuid
                }
                if name == BusinessesInterest.nameColumnName, let name = value as? String {
                    interest.name = name
                }
            }
        }
        return interest
    }

    /// Get template from row and statement
    ///
    /// - Parameters:
    ///   - row: row from database
    ///   - statement: statement from databse
    /// - Returns: template string
    private func getShareTemplateFromRowAndStatement(row: Statement.Element, statement: Statement) -> String {
        for (index, name) in statement.columnNames.enumerated() {
            if index < row.count, let value = row[index] {
                if name == BusinessesSocialShareTemplate.textColumnName {
                    if let template = value as? String {
                        return template
                    }
                }
            }
        }
        return ""
    }

    /// Get subject from row and statement
    ///
    /// - Parameters:
    ///   - row: row from database
    ///   - statement: statement from databse
    /// - Returns: subject string
    private func getShareSubjectTemplateFromRowAndStatement(row: Statement.Element, statement: Statement) -> String {
        for (index, name) in statement.columnNames.enumerated() {
            if index < row.count, let value = row[index] {
                if name == BusinessesSocialShareTemplate.subjectLineColumnName {
                    if let template = value as? String {
                        return template
                    }
                }
            }
        }
        return ""
    }
}

// MARK:- Helpers
extension DatabaseOperations {
    
    /// Connect to database
    fileprivate func loadConnection() {
        do {
            let directoryURL: String = FileHelper.fileInDocumentsDirectory(filename: AppConstants.databaseFileName)
            _database = try Connection(directoryURL)
        } catch {
            _database = nil
            log.debug("error connecting to db")
        }
    }
}
