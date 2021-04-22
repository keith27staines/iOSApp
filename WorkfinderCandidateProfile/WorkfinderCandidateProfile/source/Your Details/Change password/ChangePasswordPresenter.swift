//
//  ChangePasswordPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 15/04/2021.
//

import Foundation

class ChangePasswordPresenter: BaseAccountPresenter {
    
    enum FieldsState {
        case currentPasswordNotValid
        case newPasswordNotValid
        case confirmPasswordNotValid
        case valid
    }
    
    func fieldState(currentPassword: String, newPassword: String, confirmPassword: String) -> FieldsState {
        .currentPasswordNotValid
    }
    
    func changePassword(newPassword: String, completion: (Error?) -> Void ) {
        
    }
    
}
