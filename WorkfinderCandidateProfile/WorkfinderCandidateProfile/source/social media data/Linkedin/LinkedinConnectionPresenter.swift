//
//  LinkedinConnection.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith on 02/07/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderServices

class LinkedinConnectionPresenter: NSObject {
    
    weak var view: LinkedinConnectionViewController?
    let service: LinkedinDataServiceProtocol
    var linkedinData: LinkedinData?
    
    func onViewDidLoad(_ view: LinkedinConnectionViewController) {
        self.view = view
        let table = view.table
        table.dataSource = self
        table.register(EducationCell.self, forCellReuseIdentifier: EducationCell.reuseIdentifier)
    }
    
    func loadLinkedinConnection(completion: @escaping (Error?) -> Void) {
        service.getLinkedInData { result in
            switch result {
            case .success(let data):
                self.linkedinData = data?.extra_data
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    init(service: LinkedinDataServiceProtocol) {
        self.service = service
    }
}

extension LinkedinConnectionPresenter: UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case education
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .education:
            return linkedinData?.educations?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: EducationCell.reuseIdentifier) as? EducationCell,
            let section = Section(rawValue: indexPath.section)
        else { return UITableViewCell() }
        
        switch section {
        case .education:
            guard let educations = linkedinData?.educations else { break }
            let array = educations.values.map({$0})
            let education = array[indexPath.row]
            cell.configureWithEuduation(education)
        }
        return cell
    }
}
