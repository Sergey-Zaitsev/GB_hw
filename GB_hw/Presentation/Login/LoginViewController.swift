//
//  LoginViewController.swift
//  GB_hw
//
//  Created by Сергей Зайцев on 27.03.2022.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        configureLoginBindings()
        
    }
    func configureLoginBindings() {
        Observable
            .combineLatest(
                loginTextField.rx.text,
                passwordTextField.rx.text
            )
            .map { login, password in
                return !(login ?? "").isEmpty && (password ?? "").count >= 6
            }
            .bind { [weak loginButton] inputFilled in
                loginButton?.isEnabled = inputFilled
        }
    }
    
    @IBAction func loginPress(_ sender: UIButton){
        
        let realm = try! Realm()
        guard let login = loginTextField.text else{
            return
        }
        let password = passwordTextField.text
        let user = realm.objects(User.self).filter("login == %@",login).first
        
        if user?.passsword == password {
            performSegue(withIdentifier: "LogIn", sender: self)
        }else{
            alerts().showErrorAlert(vc: self, message: "Не верный логин или пароль")
        }
        
    }
    
    @IBAction func registrationPress(_ sender: UIButton){
        
        let realm = try! Realm()
        guard let login = loginTextField.text else{
            return
        }
        guard let password = passwordTextField.text else{
            return
        }
        let user = User()
        user.login = login
        let userForCheck = realm.objects(User.self).filter("login == %@",login).first
        if userForCheck != nil {
            let newPassword = password + "1"
            user.passsword = newPassword
            alerts().showErrorAlert(vc: self, message: "Этот пользователь уже зарегестрирован")
        }else{
            user.passsword = password
            try! realm.write {
                realm.add(user)
                performSegue(withIdentifier: "LogIn", sender: self)
            }
        }
    }
}
