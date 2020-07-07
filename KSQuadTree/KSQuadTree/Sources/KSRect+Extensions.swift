
import KSGeometry

extension KSRect {
    func quadrantRects() -> [KSQuadrantAssignment: KSRect] {
        let halfWidth = size.width/2.0
        let halfHeight = size.height/2.0
        let halfSize = KSSize(width: halfWidth, height: halfHeight)
        var rects = [KSQuadrantAssignment: KSRect]()
        rects[.bottomLeft] = KSRect(origin: origin, size: halfSize)
        rects[.topRight] = KSRect(origin: center, size: halfSize)
        rects[.topLeft] = KSRect(origin: midYPoint, size: halfSize)
        rects[.bottomRight] = KSRect(origin: midXPoint, size: halfSize)        
        return rects
    }
}
