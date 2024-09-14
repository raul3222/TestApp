//
//  RegistrationVM.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 13.09.2024.
//

import Foundation

protocol RegistrationViewModelProtocol {
    
    var readyToSignUp: Bool { get set }
    func isValidEmail(_ email: String) -> Bool
    func checkPassword(_ password: String) -> Bool
}

class RegistrationViewModel: RegistrationViewModelProtocol {
    var readyToSignUp: Bool = false
    
    func checkPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    func isValidEmail(_ email: String) -> Bool {
        if email.isEmpty {
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

       let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
       return emailPred.evaluate(with: email)
   }
}
