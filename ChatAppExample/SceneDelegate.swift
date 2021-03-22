//
//  SceneDelegate.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/03.
//

import UIKit
import Firebase
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authListener:AuthStateDidChangeListenerHandle?
    


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        guard let _ = (scene as? UIWindowScene) else { return }
        //자동로그인
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            if user != nil {
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil{
                    DispatchQueue.main.async {
                        self.goToApp()
                    }
                }
            }else{
                print("no user")
            }
        })
    }

    //자동로그인 이동
    func goToApp(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID:FUser.currentId()])
        
        let tabBarVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarViewController") as! UITabBarController
        
        //앱딜리게이트에선 프레젠트가 안됨.
        self.window?.rootViewController = tabBarVC
     
    }
    
}
