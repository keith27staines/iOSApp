//
//  RecentRolesDataSource.swift
//  WorkfinderHome
//
//  Created by Keith on 25/08/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderServices

class RecentRolesDataSource: CellPresenterProtocol {
    
    private var roles = [RoleData]()
    private var images = [UIImage]()
    
    weak var messageHandler: HSUserMessageHandler?
    let rolesService: RolesServiceProtocol
    var resultHandler: ((Error?) -> Void)?

    var error:Error? = nil
    var serverListJson: ServerListJson<RoleData>?
    var numberOfRows:Int { roles.count }
    var reloadRow: ((Int) -> Void)?
    var imageService: SmallImageServiceProtocol = SmallImageService()
    
    func roleForRow(_ row: Int) -> RoleData { roles[row] }
    
    func imageForRow(_ row: Int) -> UIImage { images[row] }
    
    private func makeDefaultImages(roles: [RoleData]) -> [UIImage] {
        roles.map { (role) -> UIImage in
            UIImage.imageWithFirstLetter(
                string: role.companyName ?? "Company name",
                backgroundColor: WorkfinderColors.primaryColor,
                width: 68)
        }
    }
    
    init(rolesService: RolesServiceProtocol, messageHandler: HSUserMessageHandler?) {
        self.rolesService = rolesService
        self.messageHandler = messageHandler
    }
    
    var pageSize: Int = 40
    var allRecentRolesCount: Int = 0
    private var nextPageUrlString: String?
    
    func clear() {
        error = nil
        allRecentRolesCount = 0
        nextPageUrlString = nil
        result = nil
        roles = []
        images = []
    }
    
    func loadFirstPage(completion: @escaping () -> Void) {
        clear()
        rolesService.fetchRecentRoles(urlString: nil) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.messageHandler?.hideLoadingOverlay()
                switch result {
                case .success(_):
                    self.result = result
                case .failure(let error):
                    self.handleError(error: error, retry: {self.loadFirstPage(completion: completion)})
                }
                self.loadingUrl = nil
                completion()
            }
        }
    }

    var loadingUrl: String? = nil
    func loadNextPage() {
        guard let nextPageUrlString = nextPageUrlString, loadingUrl != nextPageUrlString else { return }
        loadingUrl = nextPageUrlString
        messageHandler?.showLoadingOverlay(style: .transparent)
        rolesService.fetchRecentRoles(urlString: nextPageUrlString) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.messageHandler?.hideLoadingOverlay()
                switch result {
                case .success(_):
                    self.result = result
                case .failure(_):
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) { [weak self] in
                        guard let self = self else { return }
                        self.loadingUrl = nil
                        self.loadNextPage()
                    }

                }
                self.loadingUrl = nil
            }
        }
    }
    
    var lastIndexChangeSet = [Int]()

    private var result: Result<ServerListJson<RoleData>, Error>? {
        didSet {
            guard let result = result else { return }
            switch result {
            case .success(let serverListJson):
                self.serverListJson = serverListJson
                self.nextPageUrlString = serverListJson.next
                self.allRecentRolesCount = serverListJson.count ?? 0
                let lower = self.roles.count
                let upper = lower + serverListJson.results.count - 1
                lastIndexChangeSet = Array(lower ... upper)
                let deltaRoles = serverListJson.results.settingAppSource(.homeTabRecentRolesList)
                self.roles += deltaRoles
                self.images += self.makeDefaultImages(roles: deltaRoles)
                self.error = nil
            case .failure(let error):
                self.error = error
            }
            self.resultHandler?(self.error)
            self.loadImages(roles: roles)
        }
    }
    
    private func loadImages(roles: [RoleData]) {
        for i in 0..<roles.count {
            let urlString = roles[i].companyLogoUrlString
            imageService.fetchImage(urlString: urlString, defaultImage: images[i]) { [weak self] (image) in
                guard let self = self, let image = image else { return }
                self.images[i] = image
                self.reloadRow?(i)
            }
        }
    }
    
    func handleError(error: Error, retry: @escaping () -> Void) {
        guard let wfError = error as? WorkfinderError else { return }
        wfError.retryHandler = retry
        NotificationCenter.default.post(name: .wfHomeScreenErrorNotification, object: error)
    }
    
}
