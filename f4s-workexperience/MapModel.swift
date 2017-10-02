//
//  MapModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 01/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

// MARK:-
public class MapModel {

    /// All companies that can ever be shown
    private var allCompanies: [Company] = [Company]()

    /// The current bounds of the visible portion of the map
    public var visibleBounds: GMSCoordinateBounds? = nil
    
    /// Initializes a new instance of `MapModel`
    ///
    /// - parameter visibleBounds: The area that can be seen on the map
    /// - parameter allCompanies: All companies that might ever need to be presented on the map represented by this map model
    public init(visibleBounds: GMSCoordinateBounds, allCompanies:[Company]) {
        self.visibleBounds = visibleBounds
        self.quadTree = MapModel.createQuadtree(allCompanies)
    }
    
    /// Underlying spatial partitioning datastructure
    lazy var quadTree: F4SPointQuadTree = {
        let worldBounds = CGRect(x: -180.0, y: -90.0, width: 360.0, height: 180.0)
        let qt = F4SPointQuadTree(bounds: worldBounds)
        for company in self.allCompanies {
            let p = CGPoint(x: CGFloat(company.latitude), y: CGFloat(company.longitude))
            let item = F4SQuadtreeItem(point: p, object: company)
            try! qt.insert(item: item)
        }
        return qt
    }()
}

// MARK:- public API for getting companies
public extension MapModel {
    
    /// Asynchronously gets all companies within the rectangular area specified by bounds
    ///
    /// - parameter bounds: The area to be searched
    /// - parameter completion: Called to return the companies within bounds
    public func getCompaniesInsideBounds(_ bounds: GMSCoordinateBounds, completion:@escaping ([Company]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let companies = self?.companiesInsideBounds(bounds) ?? [Company]()
            completion(companies)
        }
    }
    
    /// Asynchronously gets all companies within the rectangular area represented by the current bounds
    ///
    /// - parameter completion: Called to return the companies within bounds
    public func getCompaniesInsideCurrentBounds(completion: @escaping ([Company]) -> Void) {
        guard let currentBounds = self.visibleBounds else {
            // As there are no current bounds we return an empty collection
            DispatchQueue.global(qos: .userInitiated).async {
                completion([])
            }
            return
        }
        self.getCompaniesInsideBounds(currentBounds, completion: completion)
    }
    
    /// Asynchronously gets bounds (small but not necessarily the smallest) that encloses the specified number of companies near to the specified point, or as many companies as possible after successively scaling up the bounds by the specified factor for the maximum number of allowed scalings
    ///
    /// - parameter n: The number of companies the scaled bounds must enclose
    /// - pt: Defines the center of the search
    /// - parameter maxScalings: The maximum number of scalings allowed before giving up
    /// - parameter factor: The linear factor by which the bounds are expanded on each iteration
    /// - parameter completion: Returns the bounds
    /// - returns: A small (but not necessarily the smallest) bounds that contain n companies, if that can be achieved before maxScalings has been reached. If not, the largest bounds attained when the maximum is reached. The returned bounds are guarenteed to contain `pt` if pt is located within the bounds of the Map
    public func getBoundsEnclosingAtLeast(companiesToEnclose n: Int, near pt: LatLon, maxScalings: Int = 30, factor: Double = 1.2, completion: @escaping (GMSCoordinateBounds?) -> Void ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let bounds = self?.boundsEnclosingAtLeast(companiesToEnclose: n, near: pt, maxScalings: maxScalings, factor: factor)
            completion(bounds)
        }
    }
}

// MARK: Synchronous worker functions
extension MapModel {
    /// Synchronous version of getBoundsEnclosingAtLeast. Finds bounds (small but not necessarily the smallest) that encloses the specified number of companies, or as many as possible after successively scaling up the bounds by the specified factor
    ///
    /// - parameter n: The number of companies the scaled bounds must enclose
    /// - pt: Defines the center of the search
    /// - parameter maxScalings: The maximum number of scalings allowed before giving up
    /// - parameter factor: The linear factor by which the bounds are expanded on each iteration
    /// - returns: A small (but not necessarily the smallest) bounds that contain n companies, if that can be achieved before maxScalings has been reached. If not, the largest bounds attained when the maximum is reached. The returned bounds are guarenteed to contain `pt` if pt is located within the bounds of the Map
    func boundsEnclosingAtLeast(companiesToEnclose n: Int, near pt: LatLon, maxScalings: Int = 30, factor: Double = 1.2) -> GMSCoordinateBounds? {
        let element = F4SQuadtreeItem(point: pt, object: 0)
        guard let tree = quadTree.smallestSubtreeToContain(element: element) else {
            return nil
        }
        return GMSCoordinateBounds(rect: tree.bounds)
    }
    
    /// synchrononous version of `getCompaniesInsideBounds`
    func companiesInsideBounds(_ bounds: GMSCoordinateBounds) -> [Company] {
        let rect = LatLonRect(bounds: bounds)
        let elements = quadTree.retrieveWithinRect(rect)
        let companies = elements.map { (element) -> Company in
            return element.object as! Company
        }
        return companies
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
    static func createQuadtree(_ companies: [Company]) -> F4SPointQuadTree {
        let worldBounds = CGRect(x: -180.0, y: -90.0, width: 360.0, height: 180.0)
        let qt = F4SPointQuadTree(bounds: worldBounds)
        for company in companies {
            let p = CGPoint(x: CGFloat(company.latitude), y: CGFloat(company.longitude))
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
