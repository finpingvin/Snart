//
//  AppDelegate.swift
//  Snart
//
//  Created by Daniel Björkander on 2019-03-08.
//  Copyright © 2019 Daniel Björkander. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var reminderImage: URL?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Register notification delegate
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        notificationCenter.delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { return }
        reminderImage = documentsURL.appendingPathComponent(response.notification.request.content.userInfo["imageName"] as! String)
        window?.rootViewController?.performSegue(withIdentifier: "reminder", sender: nil)
        
        completionHandler()
        
        NSLog("Did receive notfication while in background")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { return }
        reminderImage = documentsURL.appendingPathComponent(notification.request.content.userInfo["imageName"] as! String)
        window?.rootViewController?.performSegue(withIdentifier: "reminder", sender: nil)
        
        completionHandler(.sound)
        
        NSLog("Did receive notfication while in foreground")
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

