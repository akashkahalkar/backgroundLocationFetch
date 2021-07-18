//
//  AppDelegate.swift
//  BackgroundFetch
//
//  Created by akash.kahalkar on 18/07/21.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let notificationCenter = UNUserNotificationCenter.current()
    private let options: UNAuthorizationOptions = [.alert, .sound, .badge]


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        requestNotificationAuth()
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(600))
        //debug code
        if let option = launchOptions, option.keys.contains(UIApplication.LaunchOptionsKey.location) {
            triggerNotification(message: "woke due to location update")
        } else {
            triggerNotification(message: "woke due to background fetch")
        }
        return true
    }
    
    private func requestNotificationAuth() {
        notificationCenter.requestAuthorization(options: options) { (status, error) in
            if status {
                print("success")
            } else {
                print(error.debugDescription)
            }
        }
    }
    
    private func triggerNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = message
        content.subtitle = "new location update is available"
        content.sound = UNNotificationSound.default
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content, trigger: nil)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("\(Date().description) perfom bg fetch")
        UIApplication.shared.keyWindow?.rootViewController?.viewDidLoad()
        //triggerNotification(message: "woke due to background fetch")
        completionHandler(.newData)
    }
}

