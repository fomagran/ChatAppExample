//
//  ViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/03.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var repeatTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    //MARK:Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRegisterViewController" {
            let vc = segue.destination as! RegisterViewController
            
            vc.email = emailTF.text ?? ""
            vc.password = passwordTF.text ?? ""
            
        }
    }

    @IBAction func tapRegisterButton(_ sender: Any) {
        dismissKeyboard()
        if emailTF.text != "" && passwordTF.text != "" && repeatTF.text != ""{
            if passwordTF.text == repeatTF.text {
                registerUser()
            }else{
                ProgressHUD.showError("Passwords don't match")
            }
        }else{
            ProgressHUD.showError("Email and Password is missing")
        }
    }
    @IBAction func tapLoginButton(_ sender: Any) {
        dismissKeyboard()
        if emailTF.text != "" && passwordTF.text != ""{
            loginUser()
        }else{
            ProgressHUD.showError("All fields are required")
        }
    }
    
    /*스토리보드에 탭 제스쳐 레코그나이저 만들어서
     연결하면 따로 키보드 내리거나 그런거 설정할 일 없음.
     */
    @IBAction func tapBackgorund(_ sender: Any) {
        dismissKeyboard()
    }
    
    func loginUser() {
        ProgressHUD.show("Login...")
        FUser.loginUserWith(email: emailTF.text!
                            , password: passwordTF.text!) { (error) in
            if error != nil {
                ProgressHUD.showError(error.debugDescription)
                return
            }
            self.goToApp()
        }
    }
    
    func registerUser(){
        performSegue(withIdentifier: "showRegisterViewController", sender: nil)
        cleanTextFields()
        dismissKeyboard()
    }
    
    
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextFields() {
        emailTF.text = ""
        passwordTF.text = ""
        repeatTF.text = ""
    }
    
    func goToApp(){
        ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        
    }
    

}

