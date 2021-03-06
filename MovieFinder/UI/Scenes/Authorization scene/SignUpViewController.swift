//
//  LoginViewController.swift
//  MovieFinder
//
//  Created by Alexandr Nadtoka on 12/2/18.
//  Copyright © 2018 kreatimont. All rights reserved.
//

import UIKit
import SnapKit

class SignUpViewController: UIViewController, Alertable {
    
    private lazy var videoFrame: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "test_img"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return view
    }()
    
    private lazy var blurOverlay: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let bluredView = UIVisualEffectView(effect: blurEffect)
        return bluredView
    }()
    
    private lazy var usernameField: InputTextField = {
        let textField = InputTextField()
        textField.textColor = UIColor.white
        textField.backgroundColor = .clear
        textField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.keyboardType = .default
        textField.returnKeyType = .next
        return textField
    }()
    
    private lazy var emailField: InputTextField = {
        let textField = InputTextField()
        textField.textColor = UIColor.white
        textField.backgroundColor = .clear
        textField.attributedPlaceholder = NSAttributedString(string: "e-mail", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        return textField
    }()
    
    private lazy var passwordField: InputTextField = {
        let textField = InputTextField()
        textField.textColor = UIColor.white
        textField.backgroundColor = .clear
        textField.isSecureTextEntry = true
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        textField.delegate = self
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var signUpButton: ButtonBg = {
        let button = ButtonBg()
        button.setTitle("Take me here!", for: .normal)
        button.addTarget(self, action: #selector(handleLoginTap(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.gray, for: .highlighted)
        button.setTitle("Back to login", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.addTarget(self, action: #selector(handleBackToLoginTap(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 46, weight: .heavy)
        label.text = "Sign up"
        label.textColor = UIColor.white
        return label
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var client = MovieFinderClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(videoFrame)
        videoFrame.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        self.view.addSubview(blurOverlay)
        blurOverlay.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        let fieldsContainer = UIView()
        self.view.addSubview(fieldsContainer)
        fieldsContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalToSuperview().inset(16)
        }
        
        fieldsContainer.addSubview(self.emailField)
        emailField.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(30)
        }
        
        fieldsContainer.addSubview(self.usernameField)
        usernameField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.emailField.snp.bottom).offset(18)
            make.height.equalTo(30)
        }
        
        fieldsContainer.addSubview(self.passwordField)
        passwordField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.usernameField.snp.bottom).offset(18)
            make.height.equalTo(30)
        }
        
        fieldsContainer.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.passwordField.snp.bottom).offset(18)
            make.height.equalTo(40)
        }
        
        self.view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.bottom.left.equalTo(self.view.safeAreaLayoutGuide).inset(16)
        }
        
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
        }
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.fillWithTestData()
    }
    
    func fillWithTestData() {
        self.emailField.text = "nadtoka.alexandr@gmail.com"
        self.usernameField.text = "test"
        self.passwordField.text = "12345678"
    }
    
    //MARK: - action
    
    @objc func handleLoginTap(_ sender: Any?) {
        guard let email = self.emailField.text, email.count > 0 else {
            self.showAlert(title: nil, message: "Please, enter email!", buttonTitle: "OK", handler: nil)
            self.emailField.becomeFirstResponder()
            return
        }
        if !validateEmail(email) {
            self.showAlert(title: nil, message: "Please, enter valid email!", buttonTitle: "OK", handler: nil)
            return
        }
        
        guard let username = self.usernameField.text, email.count > 0 else {
            self.showAlert(title: nil, message: "Please, enter username!", buttonTitle: "OK", handler: nil)
            self.usernameField.becomeFirstResponder()
            return
        }
        
        guard let password = self.passwordField.text, email.count > 0 else {
            self.showAlert(title: nil, message: "Please, enter password!", buttonTitle: "OK", handler: nil)
            self.passwordField.becomeFirstResponder()
            return
        }
        
        let loadingOverlay = LoadingOverlay(frame: self.view.frame)
        loadingOverlay.alpha = 0
        loadingOverlay.startAnimating()
        self.view.addSubview(loadingOverlay)
        
        UIView.animate(withDuration: 0.1) {
            loadingOverlay.alpha = 1
        }
        
        _ = MovieFinderClient.register(email: email, user: username, password: password) { (success, error) in
            if success {
                _ = MovieFinderClient.login(email: email, password: password, completion: { (authToken, userId, lError) in
                    if authToken != nil && userId != nil {
                        AuthSession.current.update(authToken: authToken!, email: email, userId: userId!)
                        DispatchQueue.main.async {
                            loadingOverlay.showSuccess(compeltion: {
                                loadingOverlay.removeFromSuperview()
                                Navigator.shared.route(to: .popularMovies, wrap: .tabBar)
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            loadingOverlay.showFail(compeltion: {
                                loadingOverlay.removeFromSuperview()
                                self.showAlert(title: nil, message: lError, buttonTitle: "OK", handler: nil)
                            })
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    loadingOverlay.showFail(compeltion: {
                        loadingOverlay.removeFromSuperview()
                        self.showAlert(title: nil, message: error, buttonTitle: "OK", handler: nil)
                    })
                }
            }
        }
        
    }
    
    @objc func handleBackToLoginTap(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.usernameField.becomeFirstResponder()
            return true
        }
        if textField == self.usernameField {
            self.passwordField.becomeFirstResponder()
            return true
        }
        if textField == self.passwordField {
            //procced login
            textField.endEditing(true)
            return true
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let inputTF = textField as? InputTextField {
            inputTF.hightlight(true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let inputTF = textField as? InputTextField {
            inputTF.hightlight(false)
        }
    }
    
}
