//
//  LaunchVC.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 15.09.2024.
//

import UIKit
import FirebaseAuth

class LaunchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObserving()
    }
    
    private func startObserving() {
        let _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                ControllerManager.presentController(id: "MainVC")
            } else {
                ControllerManager.presentController(id: "LoginVC")
            }
        }
    }

}
