//
//  MapModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 01/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

public typealias F4SCompanyPinSet = Set<F4SCompanyPin>
public typealias F4SInterestSet = Set<Interest>
public typealias F4SInterestIdSet = Set<Int64>

/// Interest UUIDs are strings
public typealias F4SUUID = String

// MARK:-
public class MapModel {
    
    /// All company pins that can ever be obtained from this model
    public let allCompanyPins: F4SCompanyPinSet
    
    /// Company pins that represent companies having interests matching one or more of the selected interests
    public let filteredCompanyPinSet: F4SCompanyPinSet
    
    /// The dictionary of all interests keyed by id
    public let interestsModel: InterestsModel
    
    /// The subset of interests selected by the user
    public let selectedInterestIdSet: F4SInterestIdSet?

    /// Factory method to asynchronously create a map model
    public static func createMapModel(completion: @ escaping (MapModel) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let dbOps = DatabaseOperations.sharedInstance
            dbOps.getAllCompanies(completed: { companies in
                let userInterestList = InterestDBOperations.sharedInstance.interestsForCurrentUser()
                dbOps.getAllInterests(completed: { (interests) in
                    let mapModel = MapModel(allCompanies: companies, allInterests:interests, selectedInterests: userInterestList)
                    completion(mapModel)
                })
            })
        }
    }

    /// Underlying spatial partitioning datastructure
    fileprivate let quadTree: F4SPointQuadTree
    
    /// Initializes a new instance
    ///
    /// - parameter allCompanies: All companies that might ever need to be presented on the map represented by this map model
    public init(allCompanies:[Company],
                allInterests: [Int64:Interest],
                selectedInterests: F4SInterestSet?) {
        let companyPinsList = allCompanies.map { (company) -> F4SCompanyPin in
            return F4SCompanyPin(company: company)
        }
        let companyPinSet = F4SCompanyPinSet(companyPinsList)
        let filteredCompanyPinList: [F4SCompanyPin]
        var selectedInterestIdSet: F4SInterestIdSet? = nil
        if let selectedInterests = selectedInterests, !selectedInterests.isEmpty {
            let selectedInterestIdList = selectedInterests.map({ interest -> Int64 in
                return interest.id
            })
            selectedInterestIdSet = F4SInterestIdSet(selectedInterestIdList)
            filteredCompanyPinList = companyPinsList.filter({ pin -> Bool in
                let companyIds = Set(pin.interestIds)
                let intersection = companyIds.intersection(selectedInterestIdSet!)
                return !intersection.isEmpty
            })
        } else {
            filteredCompanyPinList = companyPinsList
        }
        allCompanyPins = companyPinSet
        self.filteredCompanyPinSet = F4SCompanyPinSet(filteredCompanyPinList)
        self.interestsModel = InterestsModel(allInterests: allInterests)
        self.selectedInterestIdSet = selectedInterestIdSet
        self.quadTree = MapModel.createQuadtree(filteredCompanyPinSet)
        //testCampdenCompanies(allCompanies: allCompanies)
    }
}

// MARK:- public API for getting interests
public extension MapModel {
    public func getInterestsInBounds(_ bounds: GMSCoordinateBounds, completion: @escaping (F4SInterestSet) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            var interestSet = F4SInterestSet()
            for companyPin in strongSelf.companyPinSetInsideBounds(bounds) {
                interestSet = interestSet.union(strongSelf.interests(from: companyPin.interestIds))
            }
            completion(interestSet)
        }
    }
}

// MARK:- public API for getting companies
public extension MapModel {

    /// Asynchronously gets all company pins within the rectangular area specified by bounds
    ///
    /// - parameter bounds: The area to be searched for pins
    /// - parameter completion: Callback to return a set of company pins
    public func getCompanyPinSet(for bounds: GMSCoordinateBounds, completion:@escaping (F4SCompanyPinSet) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let companyPins = self?.companyPinSetInsideBounds(bounds) ?? F4SCompanyPinSet()
            completion(companyPins)
        }
    }

    /// Asynchronously obtains at least `count` company pins from a rectangular region around `location` from `mapModel`
    ///
    /// - parameter count: The minimum number of companies to get
    /// - parameter location: The location at which to begin the search
    /// - parameter completion: Callback to return a set of company pins
    public func getCompanyPins(
        target count: Int,
        near location: CLLocationCoordinate2D,
        completion: @escaping (F4SCompanyPinSet) -> Void) {
        
        getBoundsEnclosing(
            target: count,
            near: location) { [weak self] bounds in
                guard let bounds = bounds, let strongSelf = self else {
                    completion([])
                    return
                }
                strongSelf.getCompanyPinSet(for: bounds) { companies in
                    completion(companies)
                }
        }
    }

    /// Asynchronously gets bounds (small but not necessarily the smallest) that encloses a specified number of company pins in the vicinity of the specified point, or as many pins as possible after successively scaling up the bounds by the specified factor for the maximum number of allowed scalings
    ///
    /// - parameter count: The target number of companies the scaled bounds should enclose
    /// - location: Defines the center of the search
    /// - parameter maxScalings: The maximum number of upward scalings allowed before giving up
    /// - parameter factor: The linear factor by which the bounds are expanded on each iteration
    /// - parameter completion: Returns the bounds that contain approximately `count` company pins, if that can be achieved before maxScalings has been reached. If not, the largest bounds attained when the maximum is reached is returned. The returned bounds are guarenteed to contain `location` if it is located within the bounds of the Map
    public func getBoundsEnclosing(
        target count: Int,
        near location: CLLocationCoordinate2D,
        maxScalings: Int = 30,
        factor: Double = 1.2,
        completion: @escaping (GMSCoordinateBounds?) -> Void ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let bounds = self?.boundsEnclosing(
                target: count,
                near: location,
                maxScalings: maxScalings,
                factor: factor)
            completion(bounds)
        }
    }
}

// MARK: Synchronous worker functions
extension MapModel {
    /// Synchronous version of getBoundsEnclosingAtLeast. Finds bounds (small but not necessarily the smallest) that encloses the specified number of companies, or as many as possible after successively scaling up the bounds by the specified factor
    ///
    /// - parameter count: The target number of pins the scaled bounds should enclose
    /// - location: Defines the center of the search
    /// - parameter maxScalings: The maximum number of scalings allowed before giving up
    /// - parameter factor: The linear factor by which the bounds are expanded on each iteration
    /// - returns: A small (but not necessarily the smallest) bounds that contain `count` company pins, if that can be achieved before maxScalings has been reached. If not, the largest bounds attained when the maximum is reached. The returned bounds are guarenteed to contain `location` if it is located within the bounds of the Map
    func boundsEnclosing(
        target count: Int,
        near location: CLLocationCoordinate2D,
        maxScalings: Int = 30,
        factor: Double = 1.2) -> GMSCoordinateBounds? {
        let pt = LatLon(location: location)
        let element = F4SQuadtreeItem(point: pt, object: 0)
        guard let tree = quadTree.smallestSubtreeToContain(element: element) else {
            return nil
        }
        let smallestBounds = GMSCoordinateBounds(rect: tree.bounds)
        let grownBounds = growBoundsToContainSpecifiedNumberOfCompanyPins(bounds: smallestBounds, target: count, maxScalings: maxScalings, factor: factor)
        return grownBounds
    }

    /// Returns the set of company pins within the specified bounds
    /// - note: This method is the synchrononous worker for `getCompaniesInsideBounds`
    func companyPinSetInsideBounds(_ bounds: GMSCoordinateBounds) -> F4SCompanyPinSet {
        let rect = LatLonRect(bounds: bounds)
        let elements = quadTree.retrieveWithinRect(rect)
        let companyPins = elements.map { element in return element.object as! F4SCompanyPin }
        let companyPinSet = F4SCompanyPinSet(companyPins)
        return companyPinSet
    }
}

// MARK:- helpers
extension MapModel {
    /// Grows the bounds until they contain the specified number of companies or the maximum number of allowed scalings have been performed
    ///
    /// - parameter bounds: The initial bounds to start scaling from (if necessary)
    /// - parameter count: The number of company pins the scaled bounds should enclose
    /// - parameter maxScalings: The maximum number of scalings allowed before giving up
    /// - parameter factor: The linear factor by which the bounds are expanded on each iteration
    /// - returns: A small (but not necessarily the smallest) bounds that contain `count` companies, if that can be achieved before maxScalings has been reached. If not, the largest bounds attained when the maximum is reached.
    func growBoundsToContainSpecifiedNumberOfCompanyPins(
        bounds: GMSCoordinateBounds,
        target count: Int,
        maxScalings: Int,
        factor: Double) -> GMSCoordinateBounds {
        var grownBounds = bounds
        var companiesInside = companyPinSetInsideBounds(grownBounds)
        var scalings = 0
        while companiesInside.count < count {
            grownBounds = bounds.scaledBy(fraction: 1.2)
            companiesInside = companyPinSetInsideBounds(grownBounds)
            scalings += 1
            if scalings >= maxScalings { break }
        }
        return grownBounds
    }

    /// Creates a quadtree populated from the collection of companies
    static func createQuadtree(_ companies: F4SCompanyPinSet) -> F4SPointQuadTree {
        let worldBounds = CGRect(x: -180.0, y: -90.0, width: 360.0, height: 180.0)
        let qt = F4SPointQuadTree(bounds: worldBounds)
        for company in companies {
            let p = CGPoint(location: company.position)
            let item = F4SQuadtreeItem(point: p, object: company)
            try! qt.insert(item: item)
        }
        return qt
    }
    
    /// Returns a set of interests from the specified list of interest ids
    func interests(from ids: [Int64]) -> F4SInterestSet {
        var interestSet = F4SInterestSet()
        for id in ids {
            guard let interest = interestsModel.allInterests[id] else { continue }
            interestSet.insert(interest)
        }
        return interestSet
    }
    /// Returns a set of interests from the specified set of interest ids
    func interests(from ids: Set<Int64>) -> F4SInterestSet {
        var interestSet = F4SInterestSet()
        for id in ids {
            guard let interest = interestsModel.allInterests[id] else { continue }
            interestSet.insert(interest)
        }
        return interestSet
    }
}

// MARK:- helper extension to facilitate transforming company pins into quadtree items
extension F4SQuadtreeItem {
    public init(companyPin: F4SCompanyPin) {
        let pt = CGPoint(location: companyPin.position)
        self.init(point: pt, object: companyPin)
    }
}

// MARK:- testing functions
extension MapModel {
    func testCampdenCompanies(allCompanies:[Company]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let url = Bundle.main.url(forResource: "camdencompanies", withExtension: "txt")!
            let s = try! NSString(contentsOf: url, encoding: 0)
            let companyNamesList: [String] = s.components(separatedBy: "\n")
            var companyNamesSet : Set<String> = Set<String>(companyNamesList)
            companyNamesSet = Set<String>(companyNamesSet.map({ string -> String in
                return string.lowercased()
            }))
            var potentialCampdenCompanies = Set<Company>()
            for company in allCompanies {
                guard let fullCompany = DatabaseOperations.sharedInstance.companyWithId(company.id) else { continue }
                let companyName = fullCompany.name.lowercased()
                if companyNamesSet.contains(companyName) {
                    potentialCampdenCompanies.insert(fullCompany)
                }
            }
            var output = String()
            let fm = NumberFormatter()
            fm.maximumIntegerDigits = 2
            fm.minimumIntegerDigits = 2
            fm.maximumFractionDigits = 4
            fm.minimumFractionDigits = 4
            fm.plusSign = "+"
            var i = 0
            for company in potentialCampdenCompanies.sorted(by: { (company1, company2) -> Bool in
                company1.name.lowercased() < company2.name.lowercased()
            }) {
                i += 1
                let lat = fm.string(from: NSNumber(value: company.latitude))!
                let lon = fm.string(from: NSNumber(value: company.longitude))!
                
                let d = distanceFromCamden(company: company)
                output += "\(i)  lat = \(lat), lon = \(lon), dist = \(d) \(company.name.lowercased())\n"
            }
            print("Done")
        }
        
        func distanceFromCamden(company: Company) -> String {
            let nf = NumberFormatter()
            nf.maximumFractionDigits = 1
            nf.minimumFractionDigits = 1
            nf.maximumIntegerDigits = 5
            nf.minimumIntegerDigits = 1
            let toRads = Double.pi / 180.0
            // 51.548833, -0.153083
            let camdenLat = 51.548833 //
            let camdenLon = -0.153083
            let r = 6371.0; // km
            let φ1 = camdenLat * toRads
            let φ2 = company.latitude * toRads
            let Δφ = (camdenLat-company.latitude) * toRads;
            let Δλ = (camdenLon-company.longitude) * toRads;
            
            let a = sin(Δφ/2) * sin(Δφ/2) +
                cos(φ1) * cos(φ2) *
                sin(Δλ/2) * sin(Δλ/2)
            let c = 2 * atan2(sqrt(a), sqrt(1-a))
            
            let d = abs(r * c);
            return nf.string(from: NSNumber(value: d))! + " km"
        }
        
    }
    
}
