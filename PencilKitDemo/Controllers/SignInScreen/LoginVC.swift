//
//  ViewController.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 12.09.2024.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    lazy var modalView = ModalView()
    lazy var coverView = UIView()
    
    var viewModel: LoginViewModelProtocol!
    var coverViewTap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginViewModel()
        bindViewModel()
        addGestures()
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
    }
    
    private func addGestures() {
        coverViewTap = UITapGestureRecognizer(target: self, action: #selector(hideModalView))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObserving()
    }
    
    private func startObserving() {
        let handler = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                ControllerManager.presentController(id: "MainVC")
            } else {
                print("not signed in")
            }
        }
    }
    
    private func showModalView() {
        view.addSubview(coverView)
        view.addSubview(modalView)
        coverView.addGestureRecognizer(coverViewTap)
        coverView.backgroundColor = .black
        coverView.alpha = 0.3
        coverView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.trailing.equalTo(view.snp.trailing)
            make.leading.equalTo(view.snp.leading)
        }
        modalView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).inset(24)
            make.trailing.equalTo(view.snp.trailing).inset(24)
            make.centerY.equalTo(view.snp.centerY)
        }
        modalView.button.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
    }
    
    @objc private func resetPassword() {
        guard let email = modalView.textField.text else { return }
        if viewModel.isValidEmail(email) {
            viewModel.resetPassword(for: email)
        }
    }
    
    @objc private func hideModalView() {
        modalView.removeFromSuperview()
        coverView.removeFromSuperview()
    }
    
    @IBAction func createAccPressed(_ sender: Any) {
        
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        guard let email = emailTF.text,
              let password = passwordTF.text else { return }
        if !viewModel.isValidEmail(email) {
            emailTF.layer.borderColor = UIColor.red.cgColor
            emailTF.layer.cornerRadius = 8
            emailTF.layer.borderWidth = 1
            return
        } else {
            emailTF.layer.borderWidth = 0
            viewModel.signIn(with: email, and: password)
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }
    }
    
    
    @IBAction func resetPasswordPressed(_ sender: Any) {
        showModalView()
    }
}

// MARK: Binding
extension LoginVC {
    private func bindViewModel() {
        viewModel.resettingPasswSuccess.bind { [weak self] success in
            guard let self = self,
                  let success = success else { return }
            if success {
                self.hideModalView()
                self.showAlert(with: "Success", subtitle: "Check your email")
            } else {
                showAlert(with: "Something went wrong", subtitle: "Check your email and try again")
            }
        }
        
        viewModel.signInSuccess.bind { [weak self] success in
            guard let self = self,
                  let success = success else { return }
            self.activityIndicator.stopAnimating()
            success ? ControllerManager.presentController(id: "MainVC") : showAlert(with: "Something went wrong", subtitle: "Check your credentials")
        }
    }
    
    private func showAlert(with title: String, subtitle: String) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

