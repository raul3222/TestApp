//
//  RegistrationVC.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 13.09.2024.
//

import UIKit
import FirebaseAuth

class RegistrationVC: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
        bindViewModel()
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        if checkEmail() && checkPassword() {
            viewModel.createAccount(with: emailTF.text ?? "", and: passwordTF.text ?? "")
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
    
    private func checkPassword() -> Bool {
        guard let password = passwordTF.text,
              let confirmPassword = confirmPasswordTF.text else { return false}
        if !viewModel.checkPassword(password) {
            passwordWarning.text = "The field should have more then 6 symbols"
            passwordWarning.isHidden = false
            return false
        } else if password != confirmPassword {
            confirmPasswWarning.text = "The passwords should be the same"
            confirmPasswWarning.isHidden = false
            return false
        } else {
            passwordWarning.isHidden = true
            confirmPasswWarning.isHidden = true
            return true
        }
    }
    
    private func checkEmail() -> Bool {
        guard let email = emailTF.text else { return false }
        if email.isEmpty {
            emailWarning.text = "Email field is required"
            emailWarning.isHidden = false
            return false
        } else if !viewModel.isValidEmail(email) {
            emailWarning.text = "Email is incorrect"
            emailWarning.isHidden = false
            return false
        } else {
            emailWarning.isHidden = true
            return true
        }
    }
    
    
    @IBAction func dismissBtnPressed(_ sender: Any) {
        dismiss(animated: true)
    }

    private func bindViewModel() {
        viewModel.successRegistration.bind { [weak self] success in
            guard let self = self,
                  let success = success else { return }
            self.activityIndicator.stopAnimating()
            if success {
                ControllerManager.presentController(id: "MainVC")
            } else {
                self.showAlert()
            }
        }
    }
    
    private func showAlert() {
        guard let error = viewModel.error else { return }
        let alert = UIAlertController(title: "Sign up error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
