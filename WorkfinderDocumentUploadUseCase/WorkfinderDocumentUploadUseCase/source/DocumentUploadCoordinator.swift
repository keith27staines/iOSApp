import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

let __bundle = Bundle(identifier: "com.f4s.WorkfinderDocumentUploadUseCase")

public class DocumentUploadCoordinator : CoreInjectionNavigationCoordinator {

    public override func start() {
        documentUploadDidFinish()
    }
    
    func documentUploadDidFinish() {
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
}
