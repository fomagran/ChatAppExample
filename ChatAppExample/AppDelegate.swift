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
import PushKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate,OSSubscriptionObserver,SINClientDelegate,SINCallClientDelegate,SINManagedPushDelegate{

    var window: UIWindow?
    var locationManager:CLLocationManager?
    var coordinates:CLLocationCoordinate2D?
    var _client:SINClient!
    var push:SINManagedPush!
    
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
        
        self.voioRegistration()
        self.push = Sinch.managedPush(with: .development)
        self.push.delegate = self
        self.push.setDesiredPushTypeAutomatically()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(USER_DID_LOGIN_NOTIFICATION),object: nil,queue: nil) { (notification) in
            let userId = notification.userInfo![kUSERID] as! String
            self.initSinchWithUserId(userId: userId)
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
    
    func initSinchWithUserId(userId: String) {
        
        if _client == nil {
            
            _client = Sinch.client(withApplicationKey: kSINCHKEY, applicationSecret: kSINCHSECRET, environmentHost: "sandbox.sinch.com", userId: userId)
            
            _client.delegate = self
            _client.call()?.delegate = self
            
            _client.setSupportCalling(true)
            _client.enableManagedPushNotifications()
            _client.start()
            _client.startListeningOnActiveConnection()
            
            
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.push.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
        
        if firebaseAuth.canHandleNotification(userInfo) {
            return
        }else {
            self.push.application(application, didReceiveRemoteNotification: userInfo)
        }
    }
    
    //MARK:SINCH DELEGATE
    
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        
        let result = SINPushHelper.queryPushNotificationPayload(payload)
        
        if result!.isCall() {
            print("incoming push payload")
            self.handleRemoteNotification(userInfo: payload as NSDictionary)
        }
    }
    
    func handleRemoteNotification(userInfo: NSDictionary) {
        
        if _client == nil {
            let userId = UserDefaults.standard.object(forKey: kUSERID)
            
            if userId != nil {
                self.initSinchWithUserId(userId: userId as! String)
            }
        }

        
        let result = self._client.relayRemotePushNotification(userInfo as? [AnyHashable : Any])
        
        if result!.isCall() {
            print("handle call notification")
        }
        
    }

    func presentMissedCallNotificationWithRemoteUserId(userId: String) {
        
        if UIApplication.shared.applicationState == .background {
            
            let center = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.title = "Missed Call"
            content.body = "From \(userId)"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
            
            center.add(request) { (error) in
                
                if error != nil {
                    print("error on notification", error!.localizedDescription)
                }
            }
        }
    }

    //MARK: SinchCallClientDelegate
    
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        
        print("will receive incoming call")
    }

    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        
        print("did receive call")
        
        //present call view
        var top = self.window?.rootViewController
        
        while (top?.presentedViewController != nil) {
            top = top?.presentedViewController
        }
        
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallVC") as! CallViewController
        
        callVC._call = call
        top?.present(callVC, animated: true, completion: nil)
    }
    
    //MARK:  SinchClintDelegate
    
    func clientDidStart(_ client: SINClient!) {
        print("Sinch did start")
    }
    
    func clientDidStop(_ client: SINClient!) {
        print("Sinch did stop")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Sinch did fail \(error.localizedDescription)")
    }

    func voioRegistration() {
        
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
}

extension AppDelegate:CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            coordinates = locationManager!.location!.coordinate
        }
    }
}

extension AppDelegate:PKPushRegistryDelegate {
    //MARK: PKPushDelegate
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        
        print("did get incoming push")
        self.handleRemoteNotification(userInfo: payload.dictionaryPayload as NSDictionary)
        
    }
}
