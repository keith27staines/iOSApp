
public protocol KSClusterRendererProtocol {
    func clear()
    func update()
    func renderClusters(_ clusters: [KSCluster])
}
