
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderServices

public class  CoverLetterFlowFactory {
    public static func makeFlow(
        type: CoverLetterFlowType,
        parent: CoverLetterParentCoordinatorProtocol?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        candidateAge: Int,
        candidateName: String?,
        isProject: Bool,
        projectTitle: String?,
        companyName:String,
        hostName: String) -> CoverLetterFlow {
        
        let templateService = TemplateProvider(
            networkConfig: inject.networkConfig,
            candidateAge: candidateAge,
            isProject: isProject
        )
        let picklistStore = PicklistsStore(
            networkConfig: inject.networkConfig,
            localStore: LocalStore())
        let logic = CoverLetterLogic(
            picklistsStore: picklistStore,
            templateService: templateService,
            companyName: companyName,
            hostName: hostName,
            candidateName: candidateName,
            projectTitle: projectTitle,
            flowType: type)
        
        switch type {
        case .passiveApplication:
            return LetterThenEditorFlow(parent: parent, navigationRouter: navigationRouter, inject: inject, logic: logic)
        case .projectApplication:
            return EditorThenLetterFlow(parent: parent, navigationRouter: navigationRouter, inject: inject, logic: logic)
        }
    }
}
