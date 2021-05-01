//
//  FeedbackChoicesPresenter.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation
import WorkfinderCommon

class SubmitPresenter: BasePresenter {
    
    var feedbackIntro: String {
        let hostName = self.hostName ?? ""
        let companyName = self.companyName ?? ""
        return "Your feedback is highly valuable to \(hostName), \(companyName) and us. This helps us improve our service so that you and other candidates won’t have similar experience again. You can choose to hide your name and details when sharing your feedback."
    }
    
    var feedbackText: String? {
        get { npsModel.feedbackText }
        set { npsModel.feedbackText = newValue }
    }
    
    var isAnonymous: Bool {
        get { npsModel.anonymous }
        set { npsModel.anonymous = newValue }
    }
    
    func submitReview(completion: @escaping (Error?) -> Void) {
        service.patchNPS(nps: npsModel) { result in
            switch result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}


