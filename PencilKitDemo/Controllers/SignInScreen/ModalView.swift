//
//  ModalView.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 13.09.2024.
//

import UIKit
import SnapKit


class ModalView: UIView {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your email"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "The confirmation email will be sent to this email dsadsa dsa das "
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your email"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 24
        button.backgroundColor = .systemBlue
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(button)
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(textField)
        self.layer.cornerRadius = 12
        self.backgroundColor = .white
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    private func setupLayout() {
        button.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.equalTo(self.snp.leading).inset(20)
            make.trailing.equalTo(self.snp.trailing).inset(20)
            make.top.equalTo(textField.snp.bottom).offset(24)
            make.bottom.equalTo(self.snp.bottom).inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).inset(24)
            make.trailing.equalTo(self.snp.trailing).inset(24)
            make.top.equalTo(self.snp.top).inset(24)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(self.snp.leading).inset(24)
            make.trailing.equalTo(self.snp.trailing).inset(24)
        }
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.leading.equalTo(self.snp.leading).inset(24)
            make.trailing.equalTo(self.snp.trailing).inset(24)
            make.top.equalTo(subtitleLabel.snp.bottom).inset(-16)
        }
    }
}
