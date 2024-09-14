//
//  ControllerPresenter.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 14.09.2024.
//

import Foundation
import UIKit

class ControllerManager {
    static func presentController(id: String) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: id)
        let scenes = UIApplication.shared.connectedScenes
        guard let windowScene = scenes.first as? UIWindowScene,
              let window = windowScene.keyWindow else { return }
        
        window.rootViewController = vc
    }
}
