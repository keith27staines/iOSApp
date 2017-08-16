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

    private var database: Connection?
    private struct BusinessesCompany {
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

    private struct BusinessesInterest {
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

    private struct BusinessesSocialShareTemplate {
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

    /// Transform a row from the database to a Company object
    ///
    /// - Parameter row: Row to transform
    /// - Returns: Company object transformed
    private func getCompanyFromRow(row: Row) -> Company {
        var company = Company()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        if let id = row[BusinessesCompany.id] {
            company.id = id
        }
        if let created = row[BusinessesCompany.created], let createdDate = formatter.date(from: created) {
            company.created = createdDate
        }
        if let modified = row[BusinessesCompany.modified], let modifiedDate = formatter.date(from: modified) {
            company.modified = modifiedDate
        }
        if let isRemoved = row[BusinessesCompany.isRemoved] {
            company.isRemoved = isRemoved
        }
        if let uuid = row[BusinessesCompany.uuid] {
            company.uuid = uuid
        }
        if let name = row[BusinessesCompany.name] {
            company.name = name
        }
        if let logoUrl = row[BusinessesCompany.logoUrl] {
            company.logoUrl = logoUrl
        }
        if let industry = row[BusinessesCompany.industry] {
            company.industry = industry
        }
        if let latitude = row[BusinessesCompany.latitude] {
            company.latitude = latitude
        }
        if let longitude = row[BusinessesCompany.longitude] {
            company.longitude = longitude
        }
        if let summary = row[BusinessesCompany.summary] {
            company.summary = summary
        }
        if let employeeCount = row[BusinessesCompany.employeeCount] {
            company.employeeCount = employeeCount
        }
        if let turnover = row[BusinessesCompany.turnover] {
            company.turnover = turnover
        }
        if let turnoverGrowth = row[BusinessesCompany.turnoverGrowth] {
            company.turnoverGrowth = turnoverGrowth
        }
        if let rating = row[BusinessesCompany.rating] {
            company.rating = rating
        }
        if let ratingCount = row[BusinessesCompany.ratingCount] {
            company.ratingCount = ratingCount
        }
        if let sourceId = row[BusinessesCompany.sourceId] {
            company.sourceId = sourceId
        }
        if let hashtag = row[BusinessesCompany.hashtag] {
            company.hashtag = hashtag
        }
        if let companyUrl = row[BusinessesCompany.companyUrl] {
            company.companyUrl = companyUrl
        }
        return company
    }

    /// Get first 30 companies in 5 miles radius with interests
    ///
    /// - Parameters:
    ///   - longitude: current location longitude
    ///   - latitude: current location latitude
    ///   - interests: list of interest selected
    ///   - completed: return list of companies
    func getCompaniesNearLocationFirstThenFilter(longitude: Double, latitude: Double, interests: [Interest], completed: @escaping (_ companies: [Company]) -> Void) {
        guard let db = database else {
            log.debug("Can't load database")
            completed([])
            return
        }
        do {
            var companyList: [Company] = []

            var companyIds: [Int64] = []
            for interest in interests {
                companyIds.append(interest.id)
            }
            let interestsStr = companyIds.flatMap({ String($0) }).joined(separator: ", ")

            let selectCompaniesNearCenterQuery: String = "SELECT *, ((((longitude + 9) - (\(longitude) + 9)) * ((longitude + 9) - (\(longitude) + 9))) + ((latitude - \(latitude)) * (latitude - \(latitude)))) AS distance FROM businesses_company WHERE latitude NOTNULL AND longitude NOTNULL AND longitude between (\(longitude) - 0.072463) AND (\(longitude) + 0.072463) AND latitude between (\(latitude) - 0.026315789) AND (\(latitude) + 0.026315789) GROUP BY latitude, longitude ORDER BY distance ASC limit 30"

            var selectCompaniesWithTheSameCoordinates: String = "SELECT businesses_company.*, COUNT(businesses_company_interests.interest_id) AS interest_count FROM businesses_company_interests JOIN businesses_company ON (businesses_company_interests.company_id = businesses_company.id AND (businesses_company.latitude NOTNULL AND businesses_company.longitude NOTNULL AND ("

            var index: Int = 0

            let stmt = try db.prepare(selectCompaniesNearCenterQuery)
            for row in stmt {
                let comp = DatabaseOperations.sharedInstance.getCompanyFromRowAndStatement(row: row, statement: stmt)
                if index != 0 {
                    selectCompaniesWithTheSameCoordinates.append("OR")
                } else {
                    index += 1
                }
                selectCompaniesWithTheSameCoordinates.append("(businesses_company.latitude = \(comp.latitude) AND businesses_company.longitude = \(comp.longitude))")
            }
            selectCompaniesWithTheSameCoordinates.append("))) WHERE businesses_company_interests.interest_id IN (\(interestsStr)) GROUP BY businesses_company_interests.company_id HAVING interest_count = \(interests.count)")

            let allCompaniesStmt = try db.prepare(selectCompaniesWithTheSameCoordinates)

            for row in allCompaniesStmt {
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

    /// Get first 30 companies in 5 miles radius
    ///
    /// - Parameters:
    ///   - longitude: current location longitude
    ///   - latitude: current location latitude
    ///   - completed: returns the company list
    func getCompaniesNearLocation(longitude: Double, latitude: Double, completed: @escaping (_ companies: [Company]) -> Void) {
        guard let db = database else {
            log.debug("Can't load database")
            completed([])
            return
        }
        do {
            var companyList: [Company] = []
            let selectCompaniesNearCenterQuery: String = "SELECT *, ((((longitude + 9) - (\(longitude) + 9)) * ((longitude + 9) - (\(longitude) + 9))) + ((latitude - \(latitude)) * (latitude - \(latitude)))) AS distance FROM businesses_company WHERE latitude NOTNULL AND longitude NOTNULL AND longitude between (\(longitude) - 0.072463) AND (\(longitude) + 0.072463) AND latitude between (\(latitude) - 0.026315789) AND (\(latitude) + 0.026315789) GROUP BY latitude, longitude ORDER BY distance ASC limit 30"

            var selectCompaniesWithTheSameCoordinates: String = "SELECT * from businesses_company where latitude NOTNULL AND longitude NOTNULL AND ("

            var index: Int = 0

            let stmt = try db.prepare(selectCompaniesNearCenterQuery)
            for row in stmt {
                let comp = DatabaseOperations.sharedInstance.getCompanyFromRowAndStatement(row: row, statement: stmt)
                if index != 0 {
                    selectCompaniesWithTheSameCoordinates.append("OR")
                } else {
                    index += 1
                }
                selectCompaniesWithTheSameCoordinates.append("(latitude = \(comp.latitude) AND longitude = \(comp.longitude))")
            }
            selectCompaniesWithTheSameCoordinates.append(")")

            let allCompaniesStmt = try db.prepare(selectCompaniesWithTheSameCoordinates)

            for row in allCompaniesStmt {
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

    /// Get first 30 companies that has the coordinates between 2 coordinates
    ///
    /// - Parameters:
    ///   - startLongitude: start coordinate longitude
    ///   - startLatitude: start coodindate latitude
    ///   - endLongitude: end coordinate longitude
    ///   - endLatitude: end coordinate latitude
    ///   - completed: return the list of companies between coordinates
    func getCompaniesInLocation(startLongitude: Double, startLatitude: Double, endLongitude: Double, endLatitude: Double, completed: @escaping (_ companies: [Company]) -> Void) {
        guard let db = database else {
            log.debug("Can't load database")
            completed([])
            return
        }
        do {
            var companyList: [Company] = []
            let selectCompaniesInLocation: String = "SELECT * FROM businesses_company WHERE latitude NOTNULL AND longitude NOTNULL AND longitude between \(startLongitude) AND \(endLongitude) AND latitude between \(startLatitude) AND \(endLatitude) ORDER BY turnover DESC, turnover_growth DESC limit 30"

            let stmt = try db.prepare(selectCompaniesInLocation)

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

    /// Get companies that has the coordinates between 2 coordinates
    ///
    /// - Parameters:
    ///   - startLongitude: start coordinate longitude
    ///   - startLatitude: start coodindate latitude
    ///   - endLongitude: end coordinate longitude
    ///   - endLatitude: end coordinate latitude
    ///   - completed: return the list of companies between coordinates
    func getCompaniesInLocationNoLimit(startLongitude: Double, startLatitude: Double, endLongitude: Double, endLatitude: Double, completed: @escaping (_ companies: [Company]) -> Void) {
        guard let db = database else {
            log.debug("Can't load database")
            completed([])
            return
        }
        do {
            var companyList: [Company] = []
            let selectCompaniesInLocation: String = "SELECT * FROM businesses_company WHERE latitude NOTNULL AND longitude NOTNULL AND longitude between \(startLongitude) AND \(endLongitude) AND latitude between \(startLatitude) AND \(endLatitude) ORDER BY turnover DESC, turnover_growth DESC"

            let stmt = try db.prepare(selectCompaniesInLocation)

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
    private func getCompanyFromRowAndStatement(row: Statement.Element, statement: Statement) -> Company {
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

    /// Return interest list of companies between 2 coordinates
    ///
    /// - Parameters:
    ///   - startLongitude: start coordinate longitude
    ///   - startLatitude: start coordinate latitude
    ///   - endLongitude: end coordinate longitude
    ///   - endLatitude: end coordinate latitude
    ///   - completed: return interest list
    func getInterestsFromArea(startLongitude: Double, startLatitude: Double, endLongitude: Double, endLatitude: Double, completed: @escaping (_ interests: [Interest]) -> Void) {
        guard let db = database else {
            log.debug("Can't load database")
            completed([])
            return
        }
        do {
            var interestsList: [Interest] = []
            let selectInterestsInLocation: String = "SELECT businesses_interest.*, SUM(CASE WHEN (businesses_company.latitude >= \(startLatitude) AND businesses_company.latitude <= \(endLatitude) AND businesses_company.longitude >= \(startLongitude) AND businesses_company.longitude <= \(endLongitude)) THEN 1 ELSE 0 END) AS interest_count FROM businesses_interest JOIN businesses_company_interests ON businesses_interest.id = businesses_company_interests.interest_id JOIN businesses_company ON (businesses_company_interests.company_id = businesses_company.id) GROUP BY businesses_interest.id ORDER BY interest_count DESC"
            let stmt = try db.prepare(selectInterestsInLocation)

            for row in stmt {
                let comp = DatabaseOperations.sharedInstance.getInterestFromRowAndStatement(row: row, statement: stmt)
                interestsList.append(comp)
            }
            completed(interestsList)
            return
        } catch {
            let nsError = error as NSError
            log.debug(nsError.localizedDescription)
            completed([])
        }
    }

    /// Get number of companies in an area with interest list
    ///
    /// - Parameters:
    ///   - startLongitude: start coordinate longitude
    ///   - startLatitude: start coordinate latitude
    ///   - endLongitude: end coordinate longitude
    ///   - endLatitude: end coordinate latitude
    ///   - interestList: list of interest selected
    ///   - completed: return number of companies and interest list
    func getCompanyCountFromArea(startLongitude: Double, startLatitude: Double, endLongitude: Double, endLatitude: Double, interestList: [Interest], completed: @escaping (_ count: Int, _ initialInterests: [Interest]) -> Void) {
        guard let db = database else {
            log.debug("Can't load database")
            completed(0, interestList)
            return
        }
        do {
            var countCompaniesInLocation: String = "SELECT businesses_company.*, COUNT(businesses_company_interests.interest_id) AS interest_count FROM businesses_company_interests JOIN businesses_company ON (businesses_company_interests.company_id = businesses_company.id AND (businesses_company.latitude >= \(startLatitude) AND businesses_company.latitude <= \(endLatitude) AND businesses_company.longitude >= \(startLongitude) AND businesses_company.longitude <= \(endLongitude))) WHERE businesses_company_interests.interest_id IN ("
            var count: Int = 0
            for interest in interestList {
                if count == 0 {
                    count += 1
                    countCompaniesInLocation.append(String(format: "%d", interest.id))
                } else {
                    countCompaniesInLocation.append(String(format: ", %d", interest.id))
                }
            }
            countCompaniesInLocation.append(")")
            countCompaniesInLocation.append("GROUP BY businesses_company_interests.company_id HAVING interest_count = \(interestList.count)")

            let stmt = try db.prepare(countCompaniesInLocation)
            var companyCount = 0
            for _ in stmt {
                companyCount += 1
            }
            completed(companyCount, interestList)
            return
        } catch {
            let nsError = error as NSError
            log.debug(nsError.localizedDescription)
            completed(0, interestList)
        }
    }

    /// Get first 30 companies between 2 coordinates that has the interests
    ///
    /// - Parameters:
    ///   - startLongitude: start coordinate longitude
    ///   - startLatitude: start coordinate latitude
    ///   - endLongitude: end coordinate longitude
    ///   - endLatitude: end coordinate latitude
    ///   - interests: interest list
    ///   - completed: return list of companies
    func getCompaniesInLocationWithFilters(startLongitude: Double, startLatitude: Double, endLongitude: Double, endLatitude: Double, interests: [Interest], completed: @escaping (_ companies: [Company]) -> Void) {
        guard let db = database else {
            log.debug("Can't load database")
            completed([])
            return
        }
        do {
            var companyList: [Company] = []
            var companyIds: [Int64] = []
            for interest in interests {
                companyIds.append(interest.id)
            }
            let interestsStr = companyIds.flatMap({ String($0) }).joined(separator: ", ")
            let selectCompaniesWithInterests: String = "SELECT businesses_company.*, COUNT(businesses_company_interests.interest_id) AS interest_count FROM businesses_company_interests JOIN businesses_company ON (businesses_company_interests.company_id = businesses_company.id AND (businesses_company.latitude >= \(startLatitude) AND businesses_company.latitude <= \(endLatitude) AND businesses_company.longitude >= \(startLongitude) AND businesses_company.longitude <= \(endLongitude))) WHERE businesses_company_interests.interest_id IN (\(interestsStr)) GROUP BY businesses_company_interests.company_id HAVING interest_count = \(interests.count) ORDER BY turnover DESC, turnover_growth DESC limit 30"

            let stmt = try db.prepare(selectCompaniesWithInterests)

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

    /// Get companies with the uuid specified
    ///
    /// - Parameters:
    ///   - withUuid: uuid of the company
    ///   - completed: return list of companies with that list
    func getCompanies(withUuid: [String], completed: @escaping (_ companies: [Company]) -> Void) {
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
    func getBusinessesSocialShareTemplateOfType(type: SocialShare) -> String {
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
    func getBusinessesSocialShareSubjectTemplateOfType(type: SocialShare) -> String {
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
                if name == BusinessesInterest.interestCountColumnName, let interestCount = value as? Int64 {
                    interest.interestCount = interestCount
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

    /// Connect to database
    private func loadConnection() {
        do {
            let directoryURL: String = FileHelper.fileInDocumentsDirectory(filename: AppConstants.databaseFileName)
            database = try Connection(directoryURL)
        } catch {
            database = nil
            log.debug("error to connect to db")
        }
    }
}
