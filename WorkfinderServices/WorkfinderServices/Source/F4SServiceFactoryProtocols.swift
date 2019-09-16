import WorkfinderCommon

/// Defines the interface for factories of objects conforming to F4SPlacementApplicationServiceProtocol
public protocol F4SPlacementApplicationServiceFactoryProtocol {
    /// Creates and returns an object conforming to F4SPlacementApplicationServiceFactoryProtocol
    func makePlacementService() -> F4SPlacementApplicationServiceProtocol
}
