import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

let __bundle = Bundle(identifier: "com.workfinder.WorkfinderDocumentUploadUseCase")

public class DocumentUploadCoordinator : CoreInjectionNavigationCoordinator {

    public override func start() {
        documentUploadDidFinish()
    }
    
    func documentUploadDidFinish() {
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
}
