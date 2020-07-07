
import GoogleMaps
import KSGeometry
import KSQuadTree

public protocol KSClusterManagerProtocol {
    var bounds: KSRect { get }
    var clusterSize: KSSize { get }
    func insertObject(x: Double, y: Double, object: Any)
    func pinLoadCompleted()
    func clear()
    func clusters() -> [KSCluster]
    func cameraDidChange()
}

public class KSGMClusterManager: NSObject, KSClusterManagerProtocol {
    
    weak var mapView: GMSMapView?
    public let bounds = KSRect(x: -180, y: -90, width: 360, height: 180)
    public var clusterSize: KSSize { KSSize(width: clusterWidth, height: clusterWidth) }
    var pins: Set<KSPin> = []
    var pinsQuadTree: KSQuadTree
    var clustersQuadTree: KSQuadTree
    let algorithm = KSClusteringAlgorithm()
    let renderer: KSClusterRendererProtocol
    var _nextPinId: Int = 0
    var oldClusterWidth: Double = 0
    private var clusterWidth: Double { visibleWidth / 4.0 }
    
    func nextPinId() -> Int {
        _nextPinId += 1
        return _nextPinId
    }
    
    public init(mapView: GMSMapView) {
        self.mapView = mapView
        pinsQuadTree = KSQuadTree(bounds: bounds)
        clustersQuadTree = KSQuadTree(bounds: bounds)
        //renderer = KSGMStaticClusterRenderer(mapView: mapView)
        renderer = KSGMAnimatedClusterRenderer(mapView: mapView)
        super.init()
        mapView.addObserver(self, forKeyPath: "camera", options: .new, context: nil)
    }
    
    public func insertObject(x: Double, y: Double, object: Any) {
        var pin = KSPin(id: nextPinId(), point: KSPoint(x: x, y: y))
        pin.object = object
        pins.insert(pin)
        try? pinsQuadTree.insert(item: pin)
    }
    
    public func pinLoadCompleted() {
        oldClusterWidth = 0
        cameraDidChange()
    }
    
    public func clear() {
        pins = []
        pinsQuadTree = KSQuadTree(bounds: bounds)
        clustersQuadTree = KSQuadTree(bounds: bounds)
        renderer.clear()
    }
    
    public func clusters() -> [KSCluster] {
        clustersQuadTree.retrieveAll().compactMap { ($0 as? KSCluster) }
    }
    
    public func cameraDidChange() {
        guard
            clusterWidth != .zero,
            isNewVisibleWidthSignificantlyDifferent(clusterWidth)
            else {
                renderer.update()
                return
        }
        algorithm.requestRebuildClusters(
            bounds: bounds,
            pins: pins,
            catchementSize: clusterSize,
            pinsQuadTree: pinsQuadTree) { [weak self] (clustersQuadTree, clusters) in
            guard let self = self else { return }
            self.clustersQuadTree = clustersQuadTree
            self.oldClusterWidth = self.clusterWidth
            self.renderer.renderClusters(clusters)
        }
    }
    
    func isNewVisibleWidthSignificantlyDifferent(_ newWidth: Double) -> Bool {
        guard newWidth != oldClusterWidth else { return false }
        guard oldClusterWidth != .zero else { return true }
        return (0.9...1.1).contains(newWidth/oldClusterWidth) ? false :  true
    }
    
    var visibleWidth: Double {
        guard let visibleRegion = mapView?.projection.visibleRegion()
            else {
                return 0.0
        }
        return abs(visibleRegion.farLeft.longitude - visibleRegion.farRight.longitude)
    }    
}

public extension KSGMClusterManager {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        cameraDidChange()
    }
}

