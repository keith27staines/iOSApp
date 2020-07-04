
public struct KSPin: XYLocatable, Hashable, Equatable {
    public let id: String
    public let point: KSPoint
    public var x: Float { point.x }
    public var y: Float { point.y }
    
    public init(id: String, point: KSPoint) {
        self.id = id
        self.point = point
    }
    
    public init(id: String, x: Float, y: Float) {
        self.init(id: id, point: KSPoint(x: x, y: y))
    }
}
