//
//  CGRect+Methods.swift
//  F4SDataStructures
//
//  Created by Keith Dev on 27/09/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import Foundation

// MARK:- CGRect extensions
extension CGRect {
    
    /// Returns a dictionary containing rectangles covering the the four quadrants of the current instance
    func quadrantRects() -> [F4SQuadtreeQuadrant : CGRect] {
        var quadrants = [F4SQuadtreeQuadrant : CGRect]()
        quadrants[.topLeft] = topLeftQuadrant()
        quadrants[.topRight] = topRightQuadrant()
        quadrants[.bottomLeft] = bottomLeftQuadrant()
        quadrants[.bottomRight] = bottomRightQuadrant()
        return quadrants
    }
    
    /// Returns true if the specified point is strictly inside the rectangle, otherwise false
    func isPointInsideBounds(_ point: CGPoint) -> Bool {
        return point.x > origin.x &&
            point.x < maxX &&
            point.y > origin.y &&
            point.y < maxY ? true : false
    }
    
    /// Returns true if the specified point is on the boundary of the rectangle, otherwise false
    func isPointOnBounds(_ point: CGPoint) -> Bool {
        if point.x == origin.x || point.x == origin.x + maxX { return true }
        if point.y == origin.y || point.y == origin.y + maxY { return true }
        return false
    }
    
    /// Returns true if the specified point is strictly outside of the rectangle, otherwise false
    func isPointOutsideBounds(_ point: CGPoint) -> Bool {
        return isPointInsideBounds(point) || isPointOnBounds(point) ? false : true
    }
    
    /// Returns the rectangle that occupies the top left quadrant of the rectangle
    func topLeftQuadrant() -> CGRect {
        return CGRect(x: minX, y: minY, width: width/2.0, height: height/2.0)
    }
    
    /// Returns the rectangle that occupies the top right quadrant of the rectangle
    func topRightQuadrant() -> CGRect {
        return CGRect(x: midX, y: minY, width: width/2.0, height: height/2.0)
    }
    
    /// Returns the rectangle that occupies the bottom left quadrant of the rectangle
    func bottomLeftQuadrant() -> CGRect {
        return CGRect(x: minX, y: midY, width: width/2.0, height: height/2.0)
    }
    
    /// Returns the rectangle that occupies the bottom left quadrant of the rectangle
    func bottomRightQuadrant() -> CGRect {
        return CGRect(x: midX, y: midY, width: width/2.0, height: height/2.0)
    }
}
