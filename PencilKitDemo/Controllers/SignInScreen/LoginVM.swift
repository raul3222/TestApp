//
//  LoginVM.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 13.09.2024.
//

import Foundation
import FirebaseAuth

protocol LoginViewModelProtocol {
    var resettingPasswSuccess: Box<Bool?> { get }
    var signInSuccess: Box<Bool?> { get }
    
    func resetPassword(for email: String)
    func signIn(with email: String, and password: String)
    func isValidEmail(_ email: String) -> Bool
}

class LoginViewModel: LoginViewModelProtocol {
    var resettingPasswSuccess: Box<Bool?> = Box(nil)
    var signInSuccess: Box<Bool?> = Box(nil)
    func resetPassword(for email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            guard let error = error else {
                self.resettingPasswSuccess.value = true
                return }
            self.resettingPasswSuccess.value = false
        }
    }
    
    func signIn(with email: String, and password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let _ = error {
                self.signInSuccess.value = false
            } else if let result = authResult {
                self.signInSuccess.value = true
                UserDefaults.standard.set(result.user.isEmailVerified, forKey: "emailVerified")
            }
        }
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
