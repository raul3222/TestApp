//
//  RegistrationVM.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 13.09.2024.
//

import Foundation
import FirebaseAuth

protocol RegistrationViewModelProtocol {
    var successRegistration: Box<Bool?> { get }
    var error: String? { get }
    func isValidEmail(_ email: String) -> Bool
    func checkPassword(_ password: String) -> Bool
    func createAccount(with email: String, and password: String)
}

class RegistrationViewModel: RegistrationViewModelProtocol {
    var error: String?
    
    var successRegistration: Box<Bool?> = Box(nil)
    
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
    
    func createAccount(with email: String, and password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error == nil {
                Auth.auth().currentUser?.sendEmailVerification()
                self.successRegistration.value = true
            } else {
                self.error = error?.localizedDescription
                self.successRegistration.value = false
            }
            
        }
    }
}
