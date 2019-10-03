
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderAppLogic
import WorkfinderUserDetailsUseCase
import WorkfinderOnboardingUseCase
import WorkfinderFavouritesUseCase
import WorkfinderCompanyDetailsUseCase
import WorkfinderRecommendations
import WorkfinderUI

class MasterBuilder: TabbarCoordinatorFactoryProtocol {
    func makeTabBarCoordinator(parent: Coordinating,
                               router: NavigationRoutingProtocol,
                               inject: CoreInjectionProtocol) -> TabBarCoordinatorProtocol {
        return TabBarCoordinator(
            parent: parent,
            navigationRouter: router,
            inject: inject,
            companyCoordinatorFactory: companyCoordinatorFactory,
            companyDocumentsService: companyDocumentsService,
            companyRepository: companyRepository,
            companyService: companyService,
            favouritesRepository: favouritesRepository,
            documentUploaderFactory: documentUploaderFactory,
            offerProcessingService: offerProcessingService,
            partnersModel: partnersModel,
            placementsRepository: placementsRepository,
            placementService: placementService,
            placementDocumentsServiceFactory: placementDocumentsServiceFactory,
            messageServiceFactory: messageServiceFactory,
            messageActionServiceFactory: messageActionServiceFactory,
            messageCannedResponsesServiceFactory: messageCannedResponsesServiceFactory,
            recommendationsService: recommendationsService,
            roleService: roleService)
    }
    
    let launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    let registrar: RemoteNotificationsRegistrarProtocol
    let apnsEnvironment: String = Config.apnsEnv
    let environment: EnvironmentType = Config.environment
    let wexApiKey = Config.wexApiKey
    let baseUrlString = Config.workfinderApiBase
    
    init(registrar: RemoteNotificationsRegistrarProtocol,
         launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.registrar = registrar
        self.launchOptions = launchOptions
    }
    
    lazy var networkConfiguration: NetworkConfig = {
        let sessionManager = F4SNetworkSessionManager(wexApiKey: wexApiKey)
        let endpoints = WorkfinderEndpoint(baseUrlString: baseUrlString)
        let networkCallLogger = NetworkCallLogger(log: log)
        let networkConfig = NetworkConfig(workfinderApiKey: wexApiKey,
                                          logger: networkCallLogger,
                                          sessionManager: sessionManager,
                                          endpoints: endpoints,
                                          userRepository: self.userRepo)
        return networkConfig
    }()
    
    lazy var appInstallationUuidLogic: AppInstallationUuidLogic = {
        let userRepo = F4SUserRepository(localStore: localStore)
        return AppInstallationUuidLogic(localStore: self.localStore,
                                        userService: userService,
                                        userRepo: userRepo,
                                        apnsEnvironment: apnsEnvironment,
                                        registerDeviceService: self.deviceRegistrationService)
    }()
    
    lazy var rootNavigationController: UINavigationController = {
        return UINavigationController(rootViewController: AppCoordinatorBackgroundViewController())
    }()
    
    lazy var rootNavigationRouter: NavigationRoutingProtocol = {
        return NavigationRouter(navigationController: self.rootNavigationController)
    }()
    
    lazy var injection: CoreInjectionProtocol = {
        return CoreInjection(
            launchOptions: self.launchOptions,
            appInstallationUuidLogic: self.appInstallationUuidLogic,
            user: self.userRepo.load(),
            userService: self.userService,
            userStatusService: self.userStatusService,
            userRepository: self.userRepo,
            databaseDownloadManager: self.databaseDownloadManager,
            contentService: self.contentService,
            log: self.log)
    }()
    
    lazy var versionCheckCoordinator: VersionCheckCoordinatorProtocol = {
        return VersionCheckCoordinator(
            parent: nil,
            navigationRouter: self.rootNavigationRouter,
            versionCheckService: self.versionCheckService)
    }()
    
    func buildAppCoordinator() -> AppCoordinatorProtocol {
        return  AppCoordinator(registrar: registrar,
                              navigationRouter: rootNavigationRouter,
                              inject: injection,
                              companyCoordinatorFactory: companyCoordinatorFactory,
                              companyDocumentsService: companyDocumentsService,
                              companyRepository: companyRepository,
                              companyService: companyService,
                              documentUploaderFactory: documentUploaderFactory,
                              emailVerificationModel: emailVerificationModel,
                              favouritesRepository: favouritesRepository,
                              localStore: localStore,
                              offerProcessingService: offerProcessingService,
                              onboardingCoordinatorFactory: onboardingCoordinatorFactory,
                              partnersModel: partnersModel,
                              placementsRepository: placementsRepository,
                              placementService: placementService,
                              placementDocumentsServiceFactory: placementDocumentsServiceFactory,
                              messageServiceFactory: messageServiceFactory,
                              messageActionServiceFactory: messageActionServiceFactory,
                              messageCannedResponsesServiceFactory: messageCannedResponsesServiceFactory,
                              recommendationsService: recommendationsService,
                              roleService: roleService,
                              tabBarCoordinatorFactory: self,
                              versionCheckCoordinator: versionCheckCoordinator)
    }
    
    lazy var companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol = {
        return CompanyCoordinatorFactory(applyService: applyService,
                                         companyFavouritesModel: companyFavouritesModel,
                                         companyService: companyService,
                                         companyDocumentService: companyDocumentsService,
                                         documentServiceFactory: placementDocumentsServiceFactory,
                                         documentUploaderFactory: documentUploaderFactory,
                                         emailVerificationModel: self.emailVerificationModel,
                                         environment: environment,
                                         getAllPlacementsService: placementService,
                                         interestsRepository: interestsRepository,
                                         placementRepository: placementsRepository,
                                         shareTemplateProvider: shareTemplateProvider,
                                         templateService: templateService)
    }()
    
    lazy var log: F4SAnalyticsAndDebugging = {
        let log = F4SLog()
        log.debug("logging started")
        return log
    }()
    
    lazy var localStore: LocalStorageProtocol = {
        return LocalStore()
    }()
    
    lazy var userRepo: F4SUserRepositoryProtocol = {
        return F4SUserRepository(localStore: self.localStore)
    }()
    
    lazy var metadataService: F4SCompanyDatabaseMetadataServiceProtocol = {
        return F4SCompanyDatabaseMetadataService(configuration: self.networkConfiguration)
    }()
    
    lazy var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol = {
        return F4SDatabaseDownloadManager(metadataService: self.metadataService)
    }()
    
    lazy var applyService: F4SPlacementApplicationServiceProtocol = {
        return F4SPlacementApplicationService(configuration: self.networkConfiguration)
    }()
    
    lazy var companyService: F4SCompanyServiceProtocol = {
        return F4SCompanyService(configuration: self.networkConfiguration)
    }()
    
    lazy var companyDocumentsService: F4SCompanyDocumentServiceProtocol = {
        return F4SCompanyDocumentService(configuration: self.networkConfiguration)
    }()
    
    lazy var companyFavouritesModel: CompanyFavouritesModel = {
        return CompanyFavouritesModel(favouritingService: self.companyFavouritingService,
                                      favouritesRepository: self.companyFavouritesRepository)
    }()
    
    lazy var companyFavouritesRepository: F4SFavouritesRepositoryProtocol = {
        return F4SFavouritesRepository()
    }()
    
    lazy var companyFavouritingService: CompanyFavouritingServiceProtocol = {
        return F4SCompanyFavouritingService(configuration: self.networkConfiguration)
    }()
    
    lazy var companyRepository:F4SCompanyRepositoryProtocol = {
        return F4SCompanyRepository()
    }()
    
    lazy var contentService: F4SContentServiceProtocol = {
        return F4SContentService(configuration: self.networkConfiguration)
    }()
    
    lazy var deviceRegistrationService: F4SDeviceRegistrationServiceProtocol = {
        return F4SDeviceRegistrationService(configuration: self.networkConfiguration)
    }()
    
    lazy var documentUploaderFactory: F4SDocumentUploaderFactoryProtocol = {
        return F4SDocumentUploaderFactory(configuration: self.networkConfiguration)
    }()
    
    lazy var emailVerificationModel: F4SEmailVerificationModel = {
        let service = self.emailVerificationServiceFactory.makeEmailVerificationService()
        return F4SEmailVerificationModel(localStore: localStore,
                                         emailVerificationService: service)
    }()
    
    lazy var emailVerificationServiceFactory: EmailVerificationServiceFactoryProtocol = {
        return EmailVerificationServiceFactory(configuration: self.networkConfiguration)
    }()
    
    lazy var favouritesRepository: F4SFavouritesRepositoryProtocol = {
        return F4SFavouritesRepository()
    }()
    
    lazy var interestsRepository: F4SInterestsRepositoryProtocol = {
        return F4SInterestsRepository()
    }()
    
    lazy var messageServiceFactory: F4SMessageServiceFactoryProtocol = {
        return F4SMessageServiceFactory(configuration: self.networkConfiguration)
    }()
    
    lazy var messageActionServiceFactory: F4SMessageActionServiceFactoryProtocol = {
        return F4SMessageActionServiceFactory(configuration: self.networkConfiguration)
    }()
    
    lazy var messageCannedResponsesServiceFactory: F4SCannedMessageResponsesServiceFactoryProtocol = {
        return F4SCannedMessageResponsesServiceFactory(configuration: self.networkConfiguration)
    }()
    
    lazy var offerProcessingService: F4SOfferProcessingServiceProtocol = {
        return F4SPlacementService(configuration: self.networkConfiguration)
    }()
    
    lazy var onboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol = {
         return OnboardingCoordinatorFactory(
            partnerService: self.partnersService,
            localStore: self.localStore)
     }()
    
    lazy var partnersModel: F4SPartnersModelProtocol = {
        return F4SPartnersModel(partnerService: self.partnersService,
                                localStore: self.localStore)
    }()
    
    lazy var partnersService: F4SPartnerServiceProtocol = {
        return F4SPartnerService(configuration: self.networkConfiguration)
    }()
    
    lazy var placementsRepository: F4SPlacementRepositoryProtocol = {
        return F4SPlacementRepository()
    }()
    
    lazy var placementService: F4SPlacementServiceProtocol = {
        return F4SPlacementService(configuration: self.networkConfiguration)
    }()
    
    lazy var getAllPlacementsService: F4SGetAllPlacementsServiceProtocol = {
        return self.placementService
    }()
    
    lazy var placementDocumentsServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol = {
        return F4SPlacementDocumentsServiceFactory(configuration: self.networkConfiguration)
    }()
    
    lazy var recommendationsService: F4SRecommendationServiceProtocol = {
        return F4SRecommendationService(configuration: self.networkConfiguration)
    }()
    
    lazy var roleService: F4SRoleServiceProtocol = {
        return F4SRoleService(configuration: self.networkConfiguration)
    }()
    
    lazy var shareTemplateProvider: ShareTemplateProviderProtocol = {
        return ShareTemplateProvider()
    }()
    
    lazy var templateService: F4STemplateServiceProtocol = {
        return F4STemplateService(configuration: self.networkConfiguration)
    }()
    
    lazy var userService: F4SUserServiceProtocol = {
        return F4SUserService(configuration: self.networkConfiguration)
    }()
    
    lazy var userStatusService: F4SUserStatusServiceProtocol = {
        return F4SUserStatusService(configuration: self.networkConfiguration)
    }()
    
    lazy var versionCheckService: F4SWorkfinderVersioningService = {
        return F4SWorkfinderVersioningService(configuration: self.networkConfiguration)
    }()

}
