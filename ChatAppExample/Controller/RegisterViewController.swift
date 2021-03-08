//
//  RegisterViewController.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/04.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {
    @IBOutlet weak var profile:UIImageView!
    @IBOutlet weak var nameTF:UITextField!
    @IBOutlet weak var subNameTF:UITextField!
    @IBOutlet weak var countryTF:UITextField!
    @IBOutlet weak var cityTF:UITextField!
    @IBOutlet weak var phoneTF:UITextField!
    
    var email:String!
    var password:String!
    var profileImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
    }
    @IBAction func tapDoneBtn(_ sender: Any) {
        self.view.endEditing(false)
        ProgressHUD.show("Registering...")
        if nameTF.text != "" && subNameTF.text != "" && countryTF.text != "" && cityTF.text != "" && phoneTF.text != "" {
            FUser.registerUserWith(email: email!, password: password!, firstName: nameTF.text!, lastName: subNameTF.text!) { (error) in
                if error != nil {
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error?.localizedDescription)
                }
                self.registerUser()
            }
        }else{
            ProgressHUD.showError("All fields ar required")
        }
    }
    
    func registerUser(){
        let fullName = nameTF.text! + " " + subNameTF.text!
        var tempDictionary:Dictionary = [kFIRSTNAME:nameTF.text!,kLASTNAME:subNameTF.text!,kFULLNAME:fullName,kCOUNTRY:countryTF.text!,kCITY:cityTF.text!,kPHONE:phoneTF.text!] as [String:Any]
        print(tempDictionary)
        
        if profileImage == nil {
            imageFromInitials(firstName: nameTF.text!, lastName: subNameTF.text!) { (image) in
                let profileIMG = image.jpegData(compressionQuality: 0.7)
                let profile = profileIMG?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
        
                tempDictionary[kAVATAR] = profile
                self.finishRegistration(withValues: tempDictionary)
            }
        }else{
            let profileIMG = profileImage?.jpegData(compressionQuality: 0.7)
            let profile = profileIMG?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
    
            tempDictionary[kAVATAR] = profile
            self.finishRegistration(withValues: tempDictionary)
        }
    }
    
    func finishRegistration(withValues:[String:Any]) {
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error?.localizedDescription)
                }
                return
            }
            ProgressHUD.dismiss()
            self.goToApp()
        }
    }
    
    func goToApp(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID:FUser.currentId()])
        
        let tabBarVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarViewController") as! UITabBarController
        
        self.navigationController?.pushViewController(tabBarVC, animated: true)
    }
    
 
}
