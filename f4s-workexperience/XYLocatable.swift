
public protocol XYLocatable {
    var x: Float { get }
    var y: Float { get }
    func isCoincidentWith(_ other: XYLocatable) -> Bool
    func distance2From(_ other: XYLocatable) -> Float
}

public extension XYLocatable {
    func isCoincidentWith(_ other: XYLocatable) -> Bool {
        x == other.x && y == other.y
    }
    func distance2From(_ other: XYLocatable) -> Float {
        (x - other.x)*(x - other.x) + (y - other.y)*(y - other.y)
    }
}
