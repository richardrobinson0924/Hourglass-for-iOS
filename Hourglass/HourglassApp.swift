//
//  HourglassApp.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import SwiftUI

@main
struct HourglassApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Model.shared)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    var shortcutItemToProcess: UIApplicationShortcutItem? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("applicationDidFinishLaunchingWithOptions")
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            self.shortcutItemToProcess = shortcutItem
        }
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.shortcutItemToProcess = shortcutItem
        completionHandler(true)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let shortcutItem = shortcutItemToProcess else { return }
        //self.shortcutItemToProcess = nil
    }
}
