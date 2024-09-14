//
//  RegistrationVC.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 13.09.2024.
//

import UIKit
import FirebaseAuth

class RegistrationVC: UIViewController {

    @IBOutlet weak var confirmPasswWarning: UILabel!
    @IBOutlet weak var passwordWarning: UILabel!
    @IBOutlet weak var emailWarning: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    
    var viewModel: RegistrationViewModelProtocol!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegistrationViewModel()

    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        checkEmail()
        checkPassword()
        if viewModel.readyToSignUp {
            createAccount()
        }
    }
    
    private func checkPassword() {
        guard let password = passwordTF.text,
              let confirmPassword = confirmPasswordTF.text else { return }
        if !viewModel.checkPassword(password) {
            passwordWarning.text = "The field should have more then 6 symbols"
            passwordWarning.isHidden = false
        } else if password != confirmPassword {
            confirmPasswWarning.text = "The passwords should be the same"
            confirmPasswWarning.isHidden = false
        } else {
            passwordWarning.isHidden = true
            viewModel.readyToSignUp = true
        }
    }
    
    private func checkEmail(){
        guard let email = emailTF.text else { return }
        if email.isEmpty {
            emailWarning.text = "Email field is required"
            emailWarning.isHidden = false
            viewModel.readyToSignUp = false
        } else if !viewModel.isValidEmail(email) {
            emailWarning.text = "Email is incorrect"
            emailWarning.isHidden = false
            viewModel.readyToSignUp = false
        } else {
            emailWarning.isHidden = true
            viewModel.readyToSignUp = true
        }
    }
    
    private func createAccount() {
        guard let email = emailTF.text,
              let passw = passwordTF.text else { return }
        Auth.auth().createUser(withEmail: email, password: passw) { authResult, error in
            if error == nil {
                Auth.auth().currentUser?.sendEmailVerification()
            }
//            Auth.auth().signIn(withEmail: email, password: passw) { [weak self] authResult, error in
//              guard let strongSelf = self else { return }
//
//            }
        }
    }
    
    
    @IBAction func dismissBtnPressed(_ sender: Any) {
        dismiss(animated: true)
    }

}
