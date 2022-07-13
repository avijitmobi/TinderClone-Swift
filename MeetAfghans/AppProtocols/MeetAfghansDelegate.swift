//
//  MeetAfghansDelegate.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 03/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit
//import GoogleSignIn
//import Firebase
//import FirebaseMessaging
import TwilioVoice
import PushKit

var audioDevice = DefaultAudioDevice()

func setDefaultAudio(){
    DefaultAudioDevice.DefaultAVAudioSessionConfigurationBlock()
}

@UIApplicationMain
class MeetAfghansDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,PKPushRegistryDelegate {
    
    var window: UIWindow?
    var voipRegistry = PKPushRegistry.init(queue: DispatchQueue.main)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let window = window{
            keyWindow = window
        }else{
            keyWindow = UIWindow(frame: UIScreen.main.bounds)
        }
//        FirebaseApp.configure()
//        UNUserNotificationCenter.current().delegate = self
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(
//            options: authOptions,
//            completionHandler: {_, _ in })
//        application.registerForRemoteNotifications()
//        Messaging.messaging().delegate = self
//        GIDSignIn.sharedInstance()?.clientID = googleClientId
        if CommonUserDefaults.accessInstance.isLogin(){
            let mainNav = Helper.getVcObject(vcName: .MainNavigationController, StoryBoardName: .Main) as! MainNavigationController
            let user = Helper.getVcObject(vcName: .ProfileVC, StoryBoardName: .Profile) as! ProfileVC
            let home = Helper.getVcObject(vcName: .SwipeCardsVC, StoryBoardName: .Main) as! SwipeCardsVC
            mainNav.viewControllers = [user,home]
            initializePushKit()
            Helper.replaceRootView(for: mainNav, animated: true)
        }else{
            let mainNav = Helper.getVcObject(vcName: .AuthNavigationController, StoryBoardName: .Main) as! AuthNavigationController
            Helper.replaceRootView(for: mainNav, animated: true)
        }
        IQKeyboardManager.shared.enable = true
        Reachablity.sharedInstance.startNotifier()
        return true
    }
    
    func initializePushKit() {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
    }
    
    func fetchVoiceAccessToken() -> String? {
        
        let endpointWithIdentity = String(format: "%@?identity=%@", CommonUserDefaults.accessInstance.get(forType: .userID) ?? "")

        guard let accessTokenURL = URL(string: baseURLString + endpointWithIdentity) else { return nil }
        print(accessTokenURL.absoluteString)
//        if let url = URL(string: baseURLString){
//            let str = try? String(contentsOf: url, encoding: .utf8)
//            let incoming = convertToDictionary(text: str ?? "")?["identity"] as? String ?? ""
//            myID_tf.text = incoming
//            print(incoming)
//            return convertToDictionary(text: str ?? "")?["token"] as? String ?? ""
//        }
        let str = try? String(contentsOf: accessTokenURL, encoding: .utf8)
//        let incoming = convertToDictionary(text: str ?? "")?["identity"] as? String ?? ""
        return convertToDictionary(text: str ?? "")?["token"] as? String ?? ""
//        return try? String(contentsOf: accessTokenURL, encoding: .utf8)
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    // MARK: PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        NSLog("pushRegistry:didUpdatePushCredentials:forType:")
        guard
            let accessToken = fetchVoiceAccessToken(),
            UserDefaults.standard.data(forKey: kCachedDeviceToken) != credentials.token
        else { return }
        
        let cachedDeviceToken = credentials.token
        /*
         * Perform registration if a new device token is detected.
         */
        TwilioVoice.register(accessToken: accessToken, deviceToken: cachedDeviceToken) { error in
            if let error = error {
                //self.view.makeToast("An error occurred while registering: \(error.localizedDescription)")
                NSLog("An error occurred while registering: \(error.localizedDescription)")
            } else {
                NSLog("Successfully registered for VoIP push notifications.")
                //self.view.makeToast("Successfully registered for VoIP push notifications.")
                /*
                 * Save the device token after successfully registered.
                 */
                UserDefaults.standard.set(cachedDeviceToken, forKey: kCachedDeviceToken)
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        NSLog("pushRegistry:didInvalidatePushTokenForType:")
        guard let deviceToken = UserDefaults.standard.data(forKey: kCachedDeviceToken),
              let accessToken = fetchVoiceAccessToken() else { return }
        
        TwilioVoice.unregister(accessToken: accessToken, deviceToken: deviceToken) { error in
            if let error = error {
                NSLog("An error occurred while unregistering: \(error.localizedDescription)")
            } else {
                NSLog("Successfully unregistered from VoIP push notifications.")
            }
        }
        UserDefaults.standard.removeObject(forKey: kCachedDeviceToken)
    }
    
    /**
     * Try using the `pushRegistry:didReceiveIncomingPushWithPayload:forType:withCompletionHandler:` method if
     * your application is targeting iOS 11. According to the docs, this delegate method is deprecated by Apple.
     */
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        NSLog("pushRegistry:didReceiveIncomingPushWithPayload:forType:")
        if let vc = (keyWindow?.rootViewController as? MainNavigationController)?.viewControllers.last{
            if let nav = (vc.presentedViewController as? UINavigationController){
                if let call = nav.viewControllers.last as? AudioVideoCallVC{
                    TwilioVoice.handleNotification(payload.dictionaryPayload, delegate: call, delegateQueue: nil)
                }else{
                    let vc = Helper.getVcObject(vcName: .AudioVideoCallVC, StoryBoardName: .Chat) as! AudioVideoCallVC
                    TwilioVoice.handleNotification(payload.dictionaryPayload, delegate:vc, delegateQueue: nil)
                    nav.pushViewController(vc, animated: true)
                }
            }else{
                let vc = Helper.getVcObject(vcName: .AudioVideoCallVC, StoryBoardName: .Chat) as! AudioVideoCallVC
                let nav = UINavigationController(rootViewController: vc)
                nav.modalTransitionStyle = .coverVertical
                nav.modalPresentationStyle = .overCurrentContext
                vc.present(nav, animated: true, completion: {
                    TwilioVoice.handleNotification(payload.dictionaryPayload, delegate: vc, delegateQueue: nil)
                })
            }
        }
    }
    
    /**
     * This delegate method is available on iOS 11 and above. Call the completion handler once the
     * notification payload is passed to the `TwilioVoice.handleNotification()` method.
     */
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        NSLog("pushRegistry:didReceiveIncomingPushWithPayload:forType:completion:")
        if let vc = (keyWindow?.rootViewController as? MainNavigationController)?.viewControllers.last{
            if let nav = (vc.presentedViewController as? UINavigationController){
                if let call = nav.viewControllers.last as? AudioVideoCallVC{
                    TwilioVoice.handleNotification(payload.dictionaryPayload, delegate: call, delegateQueue: nil)
                }else{
                    let vc = Helper.getVcObject(vcName: .AudioVideoCallVC, StoryBoardName: .Chat) as! AudioVideoCallVC
                    TwilioVoice.handleNotification(payload.dictionaryPayload, delegate:vc, delegateQueue: nil)
                    nav.pushViewController(vc, animated: true)
                }
            }else{
                let vc = Helper.getVcObject(vcName: .AudioVideoCallVC, StoryBoardName: .Chat) as! AudioVideoCallVC
                let nav = UINavigationController(rootViewController: vc)
                nav.modalTransitionStyle = .coverVertical
                nav.modalPresentationStyle = .overCurrentContext
                vc.present(nav, animated: true, completion: {
                    TwilioVoice.handleNotification(payload.dictionaryPayload, delegate: vc, delegateQueue: nil)
                })
            }
        }
        if let version = Float(UIDevice.current.systemVersion), version >= 13.0 {
            /**
             * The Voice SDK processes the call notification and returns the call invite synchronously. Report the incoming call to
             * CallKit and fulfill the completion before exiting this callback method.
             */
            completion()
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
