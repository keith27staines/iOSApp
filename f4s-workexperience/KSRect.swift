
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
    public var minX: Float { origin.x }
    public var maxX: Float { origin.x + size.width }
    public var midX: Float { (minX + maxX) / 2.0 }
    public var midY: Float { (minY + maxY) / 2.0 }
    public var minY: Float { origin.y }
    public var maxY: Float { origin.y + size.height }
    public var center: KSPoint { KSPoint(x: midX, y: midY) }
    public var midXPoint: KSPoint { return KSPoint(x: midX, y: minY) }
    public var midYPoint: KSPoint { return KSPoint(x: minX, y: midY) }
    public var maxXPoint: KSPoint { return KSPoint(x: maxX, y: minY) }
    public var maxYPoint: KSPoint { return KSPoint(x: minX, y: maxY) }
    
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

    public init(origin: KSPoint, width: Float, height: Float) {
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
    
    public init(x: Float, y: Float, width: Float, height: Float) {
        self.init(origin: KSPoint(x: x, y: y), size: KSSize(width: width, height: height))
    }
}

public extension KSRect {
    func scaled(on anchor: KSPoint, by f: Float) -> KSRect {
        let newOriginX = anchor.x + (origin.x - anchor.x)*f
        let newOriginY = anchor.y + (origin.y - anchor.y)*f
        let newOrigin = KSPoint(x: newOriginX, y: newOriginY)
        return KSRect(origin: newOrigin, size: size.scaled(by: f))
    }
}
