////
////  PopupCompanyListViewController.swift
////  f4s-workexperience
////
////  Created by Keith Dev on 14/11/2017.
////  Copyright © 2017 Founders4Schools. All rights reserved.
////
//
//import UIKit
//import WorkfinderCommon
//import WorkfinderUI
//
//protocol CompanyWorkplaceListPresenterProtocol {
//    var numberOfRows: Int { get }
//    func getCompanyWorkplaces(completion: @escaping(([CompanyWorkplace]) -> Void) )
//    func companyWorkplace(index: Int) -> CompanyWorkplace
//    func onSelectCompanyWorkplace(index: Int)
//}
//
//class CompanyWorkplaceListPresenter: CompanyWorkplaceListPresenterProtocol {
//    var workplaceUuids: [F4SUUID]
//    var workplaces = [CompanyWorkplace]()
//    var numberOfRows: Int { return workplaces.count }
//    
//    func companyWorkplace(index: Int) -> CompanyWorkplace {
//        return workplaces[index]
//    }
//    
//    func getCompanyWorkplaces(completion: @escaping (([CompanyWorkplace]) -> Void) ) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            let workplaces: [CompanyWorkplace] = []
//            self.workplaces = workplaces
//            completion(workplaces)
//        }
//    }
//    
//    func onSelectCompanyWorkplace(index: Int) {
//        
//    }
//    
//    init(workplaceUuids: [F4SUUID]) {
//        self.workplaceUuids = workplaceUuids
//    }
//}
//
//class PopupCompanyListViewController: UIViewController {
//    let screenName = ScreenName.companyClusterList
//    weak var log: F4SAnalyticsAndDebugging?
//    var didSelectCompanyWorkplace: ((CompanyWorkplace) -> Void)?
//    var presenter: CompanyWorkplaceListPresenter!
//    
//    @IBOutlet var tableView: UITableView!
//    @IBOutlet var doneButton: UIButton!
//    
//    override func viewDidLoad() {
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = UITableView.automaticDimension
//        log?.screen(screenName)
//    }
//    
//    @IBAction func doneButtonPressed(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//// MARK: - Table view data source
//extension PopupCompanyListViewController : UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return presenter.numberOfRows
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "companyInfoView", for: indexPath) as! CompanyWorkplaceCell
//        let companyWorkplace = presenter.companyWorkplace(index: indexPath.row)
//        cell.companyWorkplace = companyWorkplace
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        log?.track(event: .mapClusterShowCompanyTap, properties: nil)
//        presenter.onSelectCompanyWorkplace(index: indexPath.row)
//    }
//}
//
//class CompanyWorkplaceCell: UITableViewCell {
//    var companyWorkplace: CompanyWorkplace? {
//        didSet {
//            textLabel?.text = companyWorkplace?.companyJson.name
//        }
//    }
//}
//
//
