
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

class MasterBuilder {
    
    let launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    let registrar: RemoteNotificationsRegistrarProtocol
    
    init(registrar: RemoteNotificationsRegistrarProtocol,
         launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.registrar = registrar
        self.launchOptions = launchOptions
    }
    
    lazy var networkConfiguration: NetworkConfig = {
        let wexApiKey = Config.wexApiKey
        let baseUrlString = Config.workfinderApiBase
        let sessionManager = F4SNetworkSessionManager(wexApiKey: wexApiKey)
        let endpoints = WorkfinderEndpoint(baseUrlString: baseUrlString)
        let networkCallLogger = NetworkCallLogger(log: log)
        let networkConfig = NetworkConfig(workfinderApiKey: wexApiKey,
                                          logger: networkCallLogger,
                                          sessionManager: sessionManager,
                                          endpoints: endpoints)
        return networkConfig
    }()
    
    lazy var appInstallationUuidLogic: AppInstallationUuidLogic = {
        let userRepo = F4SUserRepository(localStore: localStore)
        return AppInstallationUuidLogic(userService: userService,
                                        userRepo: userRepo,
                                        apnsEnvironment: Config.apnsEnv,
                                        registerDeviceService: self.deviceRegistrationService)
    }()
    
    func buildAppCoordinator() -> AppCoordinatorProtocol {
        let navigationController = UINavigationController(rootViewController: AppCoordinatorBackgroundViewController())
        let navigationRouter = NavigationRouter(navigationController: navigationController)
        let injection = CoreInjection(
            launchOptions: launchOptions,
            appInstallationUuidLogic: appInstallationUuidLogic,
            user: userRepo.load(),
            userService: userService,
            userStatusService: userStatusService,
            userRepository: userRepo,
            databaseDownloadManager: databaseDownloadManager,
            contentService: contentService,
            f4sLog: log)
        let versionCheckCoordinator = VersionCheckCoordinator(parent: nil, navigationRouter: navigationRouter)
        versionCheckCoordinator.versionCheckService = versionCheckService
        
        return AppCoordinator(registrar: registrar,
                              navigationRouter: navigationRouter,
                              inject: injection,
                              companyCoordinatorFactory: companyCoordinatorFactory,
                              companyDocumentsService: companyDocumentsService,
                              companyRepository: companyRepository,
                              companyService: companyService,
                              documentUploaderFactory: documentUploaderFactory,
                              emailVerificationModel: emailVerificationModel,
                              offerProcessingService: offerProcessingService,
                              onboardingCoordinatorFactory: onboardingCoordinatorFactory,
                              partnersModel: partnersModel,
                              placementService: placementService,
                              placementDocumentsServiceFactory: placementDocumentsServiceFactory,
                              messageServiceFactory: messageServiceFactory,
                              messageActionServiceFactory: messageActionServiceFactory,
                              messageCannedResponsesServiceFactory: messageCannedResponsesServiceFactory,
                              recommendationsService: recommendationsService,
                              roleService: roleService,
                              versionCheckCoordinator: versionCheckCoordinator)
    }
    
    lazy var companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol = {
        let emailVerificationService = self.emailVerificationServiceFactory.makeEmailVerificationService()
        return CompanyCoordinatorFactory(applyService: applyService,
                                         companyFavouritesModel: companyFavouritesModel,
                                         companyService: companyService,
                                         companyDocumentService: companyDocumentsService,
                                         documentServiceFactory: placementDocumentsServiceFactory,
                                         documentUploaderFactory: documentUploaderFactory,
                                         emailVerificationService: emailVerificationService,
                                         getAllPlacementsService: placementService,
                                         interestsRepository: interestsRepository,
                                         placementRepository: placementRepository,
                                         shareTemplateProvider: shareTemplateProvider,
                                         templateService: templateService)
    }()
    
    lazy var log: F4SAnalyticsAndDebugging = {
        return F4SLog()
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
        return F4SEmailVerificationModel(emailVerificationService: service)
    }()
    
    lazy var emailVerificationServiceFactory: EmailVerificationServiceFactoryProtocol = {
        return EmailVerificationServiceFactory(configuration: self.networkConfiguration)
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
         return OnboardingCoordinatorFactory(partnerService: self.partnersService)
     }()
    
    lazy var partnersModel: F4SPartnersModel = {
        return F4SPartnersModel(partnerService: self.partnersService)
    }()
    
    lazy var partnersService: F4SPartnerServiceProtocol = {
        return F4SPartnerService(configuration: self.networkConfiguration)
    }()
    
    lazy var placementRepository: F4SPlacementRepositoryProtocol = {
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
