
public struct KSRect: Hashable, Equatable {
    
    public enum Corner {
        case bottomLeft
        case topLeft
        case bottomRight
        case topRight
    }
    public static var zero = KSRect(origin: .zero, size: .zero)
    
    public var origin: KSPoint
    public var size: KSSize
    public var minX: Double { origin.x }
    public var maxX: Double { origin.x + size.width }
    public var midX: Double { (minX + maxX) / 2.0 }
    public var midY: Double { (minY + maxY) / 2.0 }
    public var minY: Double { origin.y }
    public var maxY: Double { origin.y + size.height }
    public var center: KSPoint { KSPoint(x: midX, y: midY) }
    public var midXPoint: KSPoint { return KSPoint(x: midX, y: minY) }
    public var midYPoint: KSPoint { return KSPoint(x: minX, y: midY) }
    public var maxXPoint: KSPoint { return KSPoint(x: maxX, y: minY) }
    public var maxYPoint: KSPoint { return KSPoint(x: minX, y: maxY) }
    
    public func expandedToInclude(_ point: KSPoint) -> KSRect {
        var newOriginX = point.x < origin.x ? point.x : origin.x
        var newOriginY = point.y < origin.y ? point.y : origin.y
        let newDistalX = point.x > distalPoint.x ? point.x : distalPoint.x
        let newDistalY = point.y > distalPoint.y ? point.y : distalPoint.y
        let padding = Double.leastNormalMagnitude // smallest padding required to ensure point is inside rect rather than on the boundary of the rect
        newOriginX -= padding
        newOriginY -= padding
        let newWidth = 2 * padding + newDistalX - newOriginX
        let newHeight = 2 * padding + newDistalY - newOriginY
        let newSize = KSSize(width:newWidth, height:newHeight)
        return KSRect(origin: origin, size: newSize)
    }
    
    public var distalPoint: KSPoint {
        return KSPoint(x: origin.x + size.width, y: origin.y + size.height)
    }
    
    public func corner(_ id: Corner) -> KSPoint {
        switch id {
        case .bottomLeft: return origin
        case .topLeft: return KSPoint(x: minX, y: maxY)
        case .bottomRight: return KSPoint(x: maxX, y: minY)
        case .topRight: return distalPoint
        }
    }
    
    public func contains(_ point: XYLocatable) -> Bool {
        minX < point.x && minY < point.y && maxX > point.x && maxY > point.y
    }
    
    public func isOnOrWithinBoundary(_ point: XYLocatable) -> Bool {
        minX <= point.x && minY <= point.y && maxX >= point.x && maxY >= point.y
    }
    
    public func contains(_ rect: KSRect) -> Bool {
        return isOnOrWithinBoundary(rect.origin) && isOnOrWithinBoundary(rect.distalPoint)
    }
    
    public func intersects(_ rect: KSRect) -> Bool {
        if rect.maxX <= minX { return false }
        if rect.minX >= maxX { return false }
        if rect.maxY <= minY { return false }
        if rect.minY >= maxY { return false }
        return true
    }

    public init(origin: KSPoint, width: Double, height: Double) {
        self.origin = origin
        self.size = KSSize(width: width, height: height)
    }
    
    public init(origin: KSPoint, size: KSSize) {
        self.origin = origin
        self.size = size
    }
    
    public init(center: KSPoint, size: KSSize) {
        origin = KSPoint(x: center.x - size.width/2.0, y: center.y - size.height/2.0)
        self.size = size
    }
    
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.init(origin: KSPoint(x: x, y: y), size: KSSize(width: width, height: height))
    }
}

public extension KSRect {
    func scaled(on anchor: KSPoint, by f: Double) -> KSRect {
        let newOriginX = anchor.x + (origin.x - anchor.x)*f
        let newOriginY = anchor.y + (origin.y - anchor.y)*f
        let newOrigin = KSPoint(x: newOriginX, y: newOriginY)
        return KSRect(origin: newOrigin, size: size.scaled(by: f))
    }
}
