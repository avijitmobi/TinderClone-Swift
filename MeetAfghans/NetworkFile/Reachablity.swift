//
//  Reachablity.swift
//  AlmoFire API Calling Example
//
//  Created by Hasya.Panchasara on 01/11/17.
//  Copyright © 2017 Hasya Panchasara. All rights reserved.
//

import Foundation
import UIKit
import ReachabilitySwift

struct APPLICATION
{
    static let appDelegate = UIApplication.shared.delegate as! MeetAfghansDelegate
    
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    static var APP_STATUS_BAR_COLOR = UIColor(red: CGFloat(27.0/255.0), green: CGFloat(32.0/255.0), blue: CGFloat(42.0/255.0), alpha: 1)
    static var APP_NAVIGATION_BAR_COLOR = UIColor(red: CGFloat(41.0/255.0), green: CGFloat(48.0/255.0), blue: CGFloat(63.0/255.0), alpha: 1)
    static let applicationName = "HasyaHP"
}




class Reachablity : NSObject {
    
    //sharedInstance
    static let sharedInstance = Reachablity()
    
    
    //MARK: - Internet Reachability
    var reachability: Reachability?
    var isInternetReachable : Bool? = false
    
    func setupReachability(_ hostName: String?) {
        
       Reachablity.sharedInstance.reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        
        if reachability?.isReachable == true
        {
             Reachablity.sharedInstance.isInternetReachable = true
        }
        
        NotificationCenter.default.addObserver(Reachablity.sharedInstance, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
    }
    
    func startNotifier() {
        
        setupReachability("google.com")
        
        print("--- start notifier")
        do {
            try Reachablity.sharedInstance.reachability?.startNotifier()
        } catch {
            print("Unable to create Reachability")
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        Reachablity.sharedInstance.reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        Reachablity.sharedInstance.reachability = nil
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            Reachablity.sharedInstance.isInternetReachable = true
        } else {
            Reachablity.sharedInstance.isInternetReachable = false
        }
    }
    
   
}

/// Protocol for listenig network status change
public protocol NetworkStatusChangeListenerDelegate : class {
    
    func networkStatusDidChange(status: Reachability.NetworkStatus)
}

class NetworkManager: NSObject {
    
    //Create share instance
    var listeners = [NetworkStatusChangeListenerDelegate]()
    static let shared = NetworkManager()
    // 3. Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .notReachable
    }
    // 4. Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.NetworkStatus = .notReachable
    // 5. Reachability instance for Network status monitoring
    let reachability = Reachability()!
    
    /// Called whenever there is a change in NetworkReachibility Status
    ///
    /// — parameter notification: Notification with the Reachability instance
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            print("Not Reachable")
        case .reachableViaWiFi:
            print("Network reachable through WiFi")
        case .reachableViaWWAN:
            print("Network reachable through Cellular Data")
        }
        // Sending message to each of the delegates
        for listener in listeners {
            listener.networkStatusDidChange(status: reachability.currentReachabilityStatus)
        }
    }
    
    /// Starts monitoring the network availability status
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: ReachabilityChangedNotification,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            print("Could not start reachability notifier")
        }
    }
    
    /// Stops monitoring the network availability status
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
    
    /// Adds a new listener to the listeners array
    ///
    /// - parameter delegate: a new listener
    func addListener(listener: NetworkStatusChangeListenerDelegate){
        listeners.append(listener)
    }
    
    /// Removes a listener from listeners array
    ///
    /// - parameter delegate: the listener which is to be removed
    func removeListener(listener: NetworkStatusChangeListenerDelegate){
        listeners = listeners.filter{ $0 !== listener}
    }
}
