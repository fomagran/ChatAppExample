//
//  ViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/03.
//

import UIKit

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

    @IBAction func tapRegisterButton(_ sender: Any) {
        dismissKeyboard()
    }
    @IBAction func tapLoginButton(_ sender: Any) {
        dismissKeyboard()
    }
    
    
    /*스토리보드에 탭 제스쳐 레코그나이저 만들어서
     연결하면 따로 키보드 내리거나 그런거 설정할 일 없음.
     */
    @IBAction func tapBackgorund(_ sender: Any) {
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

}

