//
//  AppDelegate.swift
//  ChatAppExample
//
//  Created by Fomagran on 2021/03/03.
//

import UIKit
import Firebase
import CoreLocation
import OneSignal

@main
class AppDelegate: UIResponder, UIApplicationDelegate,OSSubscriptionObserver{

    var window: UIWindow?
    var locationManager:CLLocationManager?
    var coordinates:CLLocationCoordinate2D?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        requestNotificationPermission()
        requestAuthorization()
        OneSignal.add(self as OSSubscriptionObserver)
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(kONESIGNALAPPID)
        
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            
            let userID = OneSignal.getDeviceState()!.userId
            let pushToken = OneSignal.getDeviceState()!.pushToken
            
            if pushToken != nil {
                if let playerID = userID {
                    UserDefaults.standard.set(playerID,forKey: kPUSHID)
                }else {
                    UserDefaults.standard.removeObject(forKey: kPUSHID)
                }
            }
            UserDefaults.standard.synchronize()
            updateOneSignalId()
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(USER_DID_LOGIN_NOTIFICATION),object: nil,queue: nil) { (notification) in
            let userId = notification.userInfo![kUSERID] as! String
            UserDefaults.standard.set(userId, forKey: kUSERID)
            UserDefaults.standard.synchronize()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    private func requestAuthorization() {
           if locationManager == nil {
               locationManager = CLLocationManager()
               //정확도를 검사한다.
               locationManager!.desiredAccuracy = kCLLocationAccuracyBest
               //앱을 사용할때 권한요청
               locationManager!.requestWhenInUseAuthorization()
               locationManager!.delegate = self
               locationManagerDidChangeAuthorization(locationManager!)
           }else{
               //사용자의 위치가 바뀌고 있는지 확인하는 메소드
               locationManager!.startMonitoringSignificantLocationChanges()
           }
       }

    func locationManagerStop() {
        locationManager!.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("fail to get location")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinates = locations.last!.coordinate
    }
    
    func requestNotificationPermission(){
           UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow,Error in
               if didAllow {
                   print("Push: 권한 허용")
               } else {
                   print("Push: 권한 거부")
               }
           })
       }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges) {
    }
}

extension AppDelegate:CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            coordinates = locationManager!.location!.coordinate
        }
    }
}
