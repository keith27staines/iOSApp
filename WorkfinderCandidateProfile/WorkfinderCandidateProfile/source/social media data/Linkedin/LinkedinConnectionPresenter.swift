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
    
    var isLinkedinDataAvailable: Bool?
    
    func onViewDidLoad(_ view: LinkedinConnectionViewController) {
        self.view = view
        let table = view.table
        table.dataSource = self
        table.delegate = self
        table.register(GenericCell.self, forCellReuseIdentifier: GenericCell.reuseIdentifier)
    }
    
    func loadLinkedinConnection(completion: @escaping (Error?) -> Void) {
        service.getLinkedInData { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.isLinkedinDataAvailable = data != nil
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
        case skills
        case positions
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .education: return linkedinData?.educations?.count ?? 0
        case .skills: return linkedinData?.skills?.count ?? 0
        case .positions: return linkedinData?.positions?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: GenericCell.reuseIdentifier) as? GenericCell,
            let section = Section(rawValue: indexPath.section)
        else { return UITableViewCell() }
        
        switch section {
        case .education:
            guard let educations = linkedinData?.educations else { break }
            let array = educations.values.map({$0})
            let education = array[indexPath.row]
            cell.configureWithEducation(education)
        case .positions:
            guard let positions = linkedinData?.positions else { break }
            let array = positions.values.map({$0})
            let position = array[indexPath.row]
            cell.configureWithPosition(position)
        case .skills:
            guard let skills = linkedinData?.skills else { break }
            let array = skills.values.map({$0})
            let skill = array[indexPath.row]
            cell.configureWithSkill(skill)
        }
        return cell
    }
}

extension LinkedinConnectionPresenter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return "" }
        switch section {
        case .education: return "Education"
        case .skills: return "Skills"
        case .positions: return "Positions"
        }
    }
}
