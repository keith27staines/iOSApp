
import GoogleMaps

public class KSGMClusterRenderer {
    
    let mapView: GMSMapView
    let imageFactory = KSClusterImageFactory()
    private var clusters = [KSCluster]()
    private var markers = [GMSMarker]()
    private var renderedClusters = Set<KSCluster>()
    
    public init(mapView: GMSMapView) {
        self.mapView = mapView
    }
    
    public func update() {
        addOrUpdateClusters()
    }
    
    public func clear() {
        clearMarkers(markers)
        markers.removeAll()
        clusters.removeAll()
        renderedClusters.removeAll()
    }
    
    public func renderClusters(_ clusters: [KSCluster]) {
        clear()
        self.clusters = clusters
        addOrUpdateClusters()
    }
    
    private func renderCluster(_ cluster: KSCluster) {
        let location = locationFromPoint(cluster.point)
        let marker = GMSMarker(position: location)
        marker.userData = cluster
        marker.icon = imageFactory.clusterImageForCount(cluster.count)
        marker.map = mapView
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        markers.append(marker)
        renderedClusters.insert(cluster)
    }
    
    private func addOrUpdateClusters() {
        let visibleRegion = mapView.projection.visibleRegion()
        let visibleBounds = GMSCoordinateBounds(region: visibleRegion)
        for cluster in clusters {
            guard !renderedClusters.contains(cluster) else { continue }
            let location = locationFromPoint(cluster.point)
            let isClusterInBounds = visibleBounds.contains(location)
            if isClusterInBounds {
                renderCluster(cluster)
            }
        }
    }
    
    private func clearMarkers(_ markers: [GMSMarker]) {
        markers.forEach() { marker in
            marker.userData = nil
            marker.map = nil
        }
    }
    
    private func locationFromPoint(_ point: KSPoint) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: point.y, longitude: point.x)
    }
    
}
