
public class KSCluster: XYLocatable, Hashable, Equatable {
    
    public let id: String
    public let centerPin: KSPin
    public private (set) var pins: Set<KSPin>
    public var x: Float { return centerPin.x }
    public var y: Float { return centerPin.y }
    public var count: Int { return pins.count }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(centerPin)
        hasher.combine(id)
    }
    
    public static func == (lhs: KSCluster, rhs: KSCluster) -> Bool {
        lhs.centerPin == rhs.centerPin && lhs.id == rhs.id
    }
    
    public func addPin(_ pin: KSPin) {
        pins.insert(pin)
    }
    
    public init(id: String, centerPin: KSPin) {
        self.id = id
        self.centerPin = centerPin
        self.pins = Set<KSPin>([centerPin])
    }
    
    public func catchementRectangle(size: KSSize) -> KSRect {
        KSRect(center: centerPin.point, size: size)
    }
    
}
