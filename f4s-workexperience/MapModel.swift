//
//  MapModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 01/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

public typealias F4SCompanyPinSet = Set<F4SCompanyPin>
public typealias F4SInterestIdsSet = Set<Int64>

/// Interest UUIDs are strings
public typealias F4SUUID = String

// MARK:-
public struct F4SCompanyPin : Hashable {
    public let location: CLLocationCoordinate2D
    public let uuid: F4SUUID
    public let interestIds: F4SInterestIdsSet
    public let isFavourite: Bool
    
    // MARK:- Hashable conformance
    public var hashValue: Int {
        return location.latitude.hashValue ^ location.longitude.hashValue ^ uuid.hashValue
    }
    public static func ==(lhs: F4SCompanyPin, rhs: F4SCompanyPin) -> Bool {
        return
            lhs.location.latitude == rhs.location.latitude &&
            lhs.location.longitude == rhs.location.longitude  &&
            lhs.uuid == rhs.uuid
    }
    
    public func favourited() -> F4SCompanyPin {
        return F4SCompanyPin(location: location, uuid: uuid, isFavourite: true)
    }
    
    public func unfavourited() -> F4SCompanyPin {
        return F4SCompanyPin(location: location, uuid: uuid, isFavourite: false)
    }
    
    public func favouritedToggled() -> F4SCompanyPin {
        return F4SCompanyPin(location: location, uuid: uuid, isFavourite: !isFavourite)
    }
    
    /// Returns a new CompanyPin having the same properties as the current instance except that the interests includes the specified interests
    public func adding(interestIds: F4SInterestIdsSet) -> F4SCompanyPin {
        let interestsUnion = self.interestIds.union(interestIds)
        return F4SCompanyPin(location: location, uuid: uuid, isFavourite: isFavourite, interestIds: interestsUnion)
    }
    
    /// Initialize a new instance
    ///
    /// - parameter location: The latitude and longitude of the pin
    /// - parameter uuid: The id of the company the pin represents
    /// - parameter isFavourite: Indicates whether the company has been favourited
    /// - parameter interestIds: The ids of the interests of the company
    public init(
        location: CLLocationCoordinate2D,
        uuid: F4SUUID,
        isFavourite: Bool = false,
        interestIds: F4SInterestIdsSet = F4SInterestIdsSet()) {
        self.location = location
        self.uuid = uuid
        self.isFavourite = isFavourite
        self.interestIds = interestIds
    }
    
    /// Initialises a new instance from a Company
    public init(company: Company) {
        self.location = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
        self.uuid = company.uuid
        self.isFavourite = false
        self.interestIds = F4SInterestIdsSet()
    }
}

public extension F4SQuadtreeItem {
    public init(companyPin: F4SCompanyPin) {
        let pt = CGPoint(location: companyPin.location)
        self.init(point: pt, object: companyPin)
    }
}

// MARK:-
public class MapModel {

    /// All companies that can ever be obtained from this model
    private let allCompanies: F4SCompanyPinSet = F4SCompanyPinSet()

    /// The current bounds of the visible portion of the map
    public var visibleBounds: GMSCoordinateBounds? = nil
    
    /// Initializes a new instance of `MapModel`
    ///
    /// - parameter visibleBounds: The area that can be seen on the map
    /// - parameter allCompanies: All companies that might ever need to be presented on the map represented by this map model
    public init(visibleBounds: GMSCoordinateBounds? = nil,
                allCompanies:[Company]) {
        let companyPinsList = allCompanies.map { (company) -> F4SCompanyPin in
            return F4SCompanyPin(company: company)
        }
        let companyPinsSet = F4SCompanyPinSet(companyPinsList)
        self.visibleBounds = visibleBounds
        self.quadTree = MapModel.createQuadtree(companyPinsSet)
    }
    
    /// Initializes a new instance of `MapModel`
    ///
    /// - parameter visibleBounds: The area that can be seen on the map
    /// - parameter allCompanyPins: All company pins that might ever need to be presented on the map represented by this map model
    public init(visibleBounds: GMSCoordinateBounds? = nil,
                allCompanyPins:F4SCompanyPinSet) {
        self.visibleBounds = visibleBounds
        self.quadTree = MapModel.createQuadtree(allCompanies)
    }
    
    /// Underlying spatial partitioning datastructure
    let quadTree: F4SPointQuadTree
    
    public func getInterests(within bounds:GMSCoordinateBounds, completion: @escaping ([Interest]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            completion([Interest]())
        }
    }
}

// MARK:- public API for getting companies
public extension MapModel {
    
    /// Asynchronously gets all companies within the rectangular area specified by bounds
    ///
    /// - parameter bounds: The area to be searched
    /// - parameter completion: Called to return the companies within bounds
    public func getCompaniesInsideBounds(_ bounds: GMSCoordinateBounds, completion:@escaping (F4SCompanyPinSet) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let companies = self?.companiesInsideBounds(bounds) ?? F4SCompanyPinSet()
            completion(companies)
        }
    }
    
    /// Asynchronously gets all companies within the rectangular area represented by the current bounds
    ///
    /// - parameter completion: Called to return the companies within bounds
    public func getCompaniesInsideCurrentBounds(completion: @escaping (F4SCompanyPinSet) -> Void) {
        guard let currentBounds = self.visibleBounds else {
            // As there are no current bounds we return an empty collection
            DispatchQueue.global(qos: .userInitiated).async {
                completion([])
            }
            return
        }
        self.getCompaniesInsideBounds(currentBounds, completion: completion)
    }
    
    /// Asynchronously obtains at least `n` companies from a rectangular region around `location` from `mapModel`
    ///
    /// - parameter n: The minimum number of companies to get
    /// - parameter mapModel: The MapModel to search
    /// - parameter location: The location at which to begin the search
    /// - parameter completion: Returns the collection of companies
    public func getCompanies(
        atLeast n: Int,
        from mapModel: MapModel,
        near location: CLLocationCoordinate2D,
        completion: @escaping (F4SCompanyPinSet) -> Void) {
        getBoundsEnclosingAtLeast(
            companiesToEnclose: n,
            near: location) { [weak self] bounds in
                guard let bounds = bounds, let strongSelf = self else {
                    completion([])
                    return
                }
                strongSelf.getCompaniesInsideBounds(bounds) { companies in
                    completion(companies)
                }
        }
    }
    
    /// Asynchronously gets bounds (small but not necessarily the smallest) that encloses the specified number of companies near to the specified point, or as many companies as possible after successively scaling up the bounds by the specified factor for the maximum number of allowed scalings
    ///
    /// - parameter n: The number of companies the scaled bounds must enclose
    /// - location: Defines the center of the search
    /// - parameter maxScalings: The maximum number of scalings allowed before giving up
    /// - parameter factor: The linear factor by which the bounds are expanded on each iteration
    /// - parameter completion: Returns the bounds
    /// - returns: A small (but not necessarily the smallest) bounds that contain n companies, if that can be achieved before maxScalings has been reached. If not, the largest bounds attained when the maximum is reached. The returned bounds are guarenteed to contain `pt` if pt is located within the bounds of the Map
    public func getBoundsEnclosingAtLeast(
        companiesToEnclose n: Int,
        near location: CLLocationCoordinate2D,
        maxScalings: Int = 30,
        factor: Double = 1.2,
        completion: @escaping (GMSCoordinateBounds?) -> Void ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let bounds = self?.boundsEnclosingAtLeast(
                companiesToEnclose: n,
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
    /// - parameter n: The number of companies the scaled bounds must enclose
    /// - location: Defines the center of the search
    /// - parameter maxScalings: The maximum number of scalings allowed before giving up
    /// - parameter factor: The linear factor by which the bounds are expanded on each iteration
    /// - returns: A small (but not necessarily the smallest) bounds that contain n companies, if that can be achieved before maxScalings has been reached. If not, the largest bounds attained when the maximum is reached. The returned bounds are guarenteed to contain `pt` if pt is located within the bounds of the Map
    func boundsEnclosingAtLeast(
        companiesToEnclose n: Int,
        near location: CLLocationCoordinate2D,
        maxScalings: Int = 30,
        factor: Double = 1.2) -> GMSCoordinateBounds? {
        let pt = LatLon(location: location)
        let element = F4SQuadtreeItem(point: pt, object: 0)
        guard let tree = quadTree.smallestSubtreeToContain(element: element) else {
            return nil
        }
        return GMSCoordinateBounds(rect: tree.bounds)
    }
    
    /// synchrononous version of `getCompaniesInsideBounds`
    func companiesInsideBounds(_ bounds: GMSCoordinateBounds) -> F4SCompanyPinSet {
        let rect = LatLonRect(bounds: bounds)
        let elements = quadTree.retrieveWithinRect(rect)
        let companies = elements.map { (element) -> F4SCompanyPin? in
            return element.object as? F4SCompanyPin
        }
        let companiesSet = F4SCompanyPinSet(companies)
        return companiesSet
    }
}

// MARK:- helpers
extension MapModel {
    /// Grows the bounds until they contain the specified number of companies or the maximum number of allowed scalings have been performed
    ///
    /// - parameter bounds: The initial bounds to start scaling from (if necessary)
    /// - parameter n: The number of companies the scaled bounds must enclose
    /// - parameter maxScalings: The maximum number of scalings allowed before giving up
    /// - parameter factor: The linear factor by which the bounds are expanded on each iteration
    /// - returns: A small (but not necessarily the smallest) bounds that contain n companies, if that can be achieved before maxScalings has been reached. If not, the largest bounds attained when the maximum is reached.
    func growBoundsToContainNumberOfCompanies(bounds: GMSCoordinateBounds, companies n: Int, maxScalings: Int, factor: Double) -> GMSCoordinateBounds {
        var grownBounds = bounds
        var companiesInside = companiesInsideBounds(grownBounds)
        var scalings = 0
        while companiesInside.count < n {
            grownBounds = bounds.scaledBy(fraction: 1.2)
            companiesInside = companiesInsideBounds(grownBounds)
            scalings += 1
            if scalings >= 30 { break }
        }
        return grownBounds
    }

    /// Creates a quadtree populated from the collection of companies
    static func createQuadtree(_ companies: F4SCompanyPinSet) -> F4SPointQuadTree {
        let worldBounds = CGRect(x: -180.0, y: -90.0, width: 360.0, height: 180.0)
        let qt = F4SPointQuadTree(bounds: worldBounds)
        for company in companies {
            let p = CGPoint(location: company.location)
            let item = F4SQuadtreeItem(point: p, object: company)
            try! qt.insert(item: item)
        }
        return qt
    }
}


// MARK:-
extension Company : Hashable {
    public var hashValue: Int {
        return latitude.hashValue ^ longitude.hashValue ^ uuid.hashValue
    }
    
    public static func ==(lhs: Company, rhs: Company) -> Bool {
        return lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude && lhs.uuid == rhs.uuid
    }
}
