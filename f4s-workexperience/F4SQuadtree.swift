//
//  F4SQuadtreeProtocol.swift
//  F4SDataStructures
//
//  Created by Keith Dev on 26/09/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import Foundation

// MARK:-
public enum F4SPointQuadtreeError : Error {
    case itemNotWithinBounds
}

// MARK:-
/// Represents the quadrant that an item lies within
public enum F4SQuadtreeQuadrant {
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
    /// Cannot be assigned to a quadrant (e.g. it is on a boundary) but is contained within the parent
    case useOwnBounds
    /// Not contained at all
    case none
}

// MARK:-
public protocol F4SQuadtreeElement {
    var point: CGPoint { get }
    var object: AnyHashable { get }
}

public struct F4SQuadtreeItem : F4SQuadtreeElement {
    public static func ==(lhs: F4SQuadtreeItem, rhs: F4SQuadtreeItem) -> Bool {
        return lhs.point == rhs.point && lhs.object == rhs.object
    }
    
    public var hashValue: Int { return
        self.point.x.hashValue ^ self.point.y.hashValue ^ object.hashValue
    }
    public var point: CGPoint
    public var object: AnyHashable
    public init(point: CGPoint, object: AnyHashable) {
        self.point = point
        self.object = object
    }
}

// MARK:-
public protocol F4SPointQuadtreeProtocol {
    /// The maximum number of items that the current instance can hold without splitting (assuming the maximum depth has not been reached)
    var maxItems: Int { get }
    /// The nesting depth for the current instance. If the max depth is reached, the subtree will not split
    var depth: Int { get }
    /// The bounding rectangle for the current instance
    var bounds: CGRect { get }
    /// The points directly contained within this instance (excludes points assigned to subtrees of this instance)
    var items: [F4SQuadtreeElement] { get }
    /// Clears the current instance and all substrees
    func clear()
    /// Returns the quadrant of an item.
    func quadrant(for item: F4SQuadtreeElement) -> F4SQuadtreeQuadrant
    /// Returns the subtrees within the current instance
    var subtreeDictionary : [F4SQuadtreeQuadrant : F4SPointQuadtreeProtocol]? { get }
    /// Inserts a new point into the subtree
    func insert(item: F4SQuadtreeElement) throws
    /// Inserts points into the subtree
    func insert(items: [F4SQuadtreeElement]) throws
    /// Retrieve all items contained within the subtree
    func retrieveAll() -> [F4SQuadtreeElement]
    /// Retrieve all items in the tree that lie within the specified rect
    func retrieveWithinRect(_ rect: CGRect) -> [F4SQuadtreeElement]
}

// MARK:-
public class F4SPointQuadTree : F4SPointQuadtreeProtocol {
    
    public var items: [F4SQuadtreeElement]
    public let maxItems: Int
    public let depth: Int
    public var subtreeDictionary: [F4SQuadtreeQuadrant:F4SPointQuadtreeProtocol]? = nil
    public let bounds: CGRect
    
    ///
    public convenience init(bounds: CGRect, depth: Int = 30, maxItems: Int = 30) {
        try! self.init(bounds: bounds, items: nil, depth: depth, maxItems: maxItems)
    }
    
    public init(bounds: CGRect, items: [F4SQuadtreeElement]?, depth: Int = 30, maxItems: Int = 30) throws {
        precondition(bounds.size != CGSize.zero, "Bounds cannot be zero")
        self.bounds = bounds
        self.maxItems = maxItems
        self.depth = depth
        self.items = [F4SQuadtreeElement]()
        guard let items = items else {
            return
        }
        try insert(items: items)
    }
    
    public func clear() {
        items.removeAll()
        subtreeDictionary = nil
    }
    
    public func insert(items: [F4SQuadtreeElement]) throws {
        try items.forEach() { (item) in
            try insert(item: item)
        }
    }
    
    public func retrieveWithinRect(_ rect: CGRect) -> [F4SQuadtreeElement] {
        guard rect.intersects(bounds) else {
            return [F4SQuadtreeElement]()
        }
        let items = retrieveAll()
        let itemsInside = items.filter { (item) -> Bool in
            return rect.contains(item.point)
        }
        return itemsInside
    }
    
    public func retrieveAll() -> [F4SQuadtreeElement] {
        var items = self.items
        if let subtrees = subtreeDictionary {
            for tree in subtrees {
                items += tree.value.retrieveAll()
            }
        }
        return items
    }
    
    public func insert(item: F4SQuadtreeElement) throws {
        let quadrant = self.quadrant(for: item)
        switch quadrant {
        case .none:
            // The item lies
            throw F4SPointQuadtreeError.itemNotWithinBounds
        case .useOwnBounds:
            // The item is lying on the mid-lines of the the current instance so must be assigned to the current instance's own array of items because it cannot be uniquely assigned to a quadrant
            items.append(item)
        default:
            // The item does lie in a well defined quadrant
            guard depth > 0 else {
                // The current instance is at the maximum depth allowed, so no more splitting is allowed. Therefore inserts must be added to the current instance's own array of items
                items.append(item)
                return
            }
            guard let subtrees = subtreeDictionary else {
                // Split this subtree into 4 subtrees and reassign items to the subtrees where possible
                items.append(item)
                if items.count > maxItems {
                    split()
                }
                return
            }
            // assign the new item to the appropriate quadrant
            let subtree = subtrees[quadrant]!
            try subtree.insert(item: item)
        }
    }
    
    /// Splits the current instance by creating 4 subtrees and moving as many of its items to the subtrees as possible
    private func split() {
        // `remainingItems` will hold all the items that cannot be assigned to subtrees
        var remainingItems = [F4SQuadtreeElement]()
        let subtreeDictionary = createSubtreeDictionary()
        for item in items {
            let quadrant = self.quadrant(for: item)
            if let subtree = subtreeDictionary[quadrant] {
                // There is an appropriate subtree to home this item
                try! subtree.insert(item: item)
            } else {
                // We can't put this item in a subtree so we keep it ourselves
                remainingItems.append(item)
            }
        }
        // The items that couldn't be assigned to subtrees must be retained by us
        items = remainingItems
        self.subtreeDictionary = subtreeDictionary
    }
    
    /// Returns a dictionary containing new sub-quadtrees for the current instance
    func createSubtreeDictionary() -> [F4SQuadtreeQuadrant : F4SPointQuadtreeProtocol] {
        let rects = bounds.quadrantRects()
        var subtrees = [F4SQuadtreeQuadrant:F4SPointQuadTree]()
        subtrees[.topLeft] = try! F4SPointQuadTree(bounds: rects[.topLeft]!, items: nil, depth: depth - 1, maxItems: maxItems)
        subtrees[.topRight] = try! F4SPointQuadTree(bounds: rects[.topRight]!, items: nil, depth: depth - 1, maxItems: maxItems)
        subtrees[.bottomLeft] = try! F4SPointQuadTree(bounds: rects[.bottomLeft]!, items: nil, depth: depth - 1, maxItems: maxItems)
        subtrees[.bottomRight] = try! F4SPointQuadTree(bounds: rects[.bottomRight]!, items: nil, depth: depth - 1, maxItems: maxItems)
        return subtrees
    }
    
    /// Returns the quadrant in which the item lies
    public func quadrant(for item: F4SQuadtreeElement) -> F4SQuadtreeQuadrant {
        let point = item.point
        if !bounds.isPointInsideBounds(point){
            return .none // point is outside our bounds or on our boundary which counts as outside
        }
        if point.x == bounds.midX || point.y == bounds.midY {
            return .useOwnBounds // point is on one of our midlines and therefore cannot be assigned to a quadrant
        }
        if point.x < bounds.midX {
            // point lies within the top-left or bottom-left quadrant
            return point.y < bounds.midY ? .topLeft : .bottomLeft
        } else {
            // point lies within the top-right or bottom-right quadrant
            return point.y < bounds.midY ? .topRight : .bottomRight
        }
    }
}




















