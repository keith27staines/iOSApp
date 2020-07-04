
public protocol XYLocatable {
    var x: Double { get }
    var y: Double { get }
    func isCoincidentWith(_ other: XYLocatable) -> Bool
    func distance2From(_ other: XYLocatable) -> Double
}

public extension XYLocatable {
    func isCoincidentWith(_ other: XYLocatable) -> Bool {
        x == other.x && y == other.y
    }
    func distance2From(_ other: XYLocatable) -> Double {
        (x - other.x)*(x - other.x) + (y - other.y)*(y - other.y)
    }
}
