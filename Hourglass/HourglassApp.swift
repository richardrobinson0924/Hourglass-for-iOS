//
//  HourglassApp.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import SwiftUI
import CoreData

struct ShortcutItemEnvironmentKey: EnvironmentKey {
    static let defaultValue: UIApplicationShortcutItem? = nil
}

extension EnvironmentValues {
    var shortcutItem: UIApplicationShortcutItem? {
        get { self[ShortcutItemEnvironmentKey] }
        set {
            print("setting shortcutItem to \(String(describing: newValue))")
            self[ShortcutItemEnvironmentKey] = newValue
        }
    }
}

@main
struct HourglassApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let container: NSPersistentContainer = {
        let pc = NSPersistentContainer(name: "Model")
        pc.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        return pc
    }()
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, container.viewContext)
                .onDisappear {
                    saveContext()
                }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if (launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem) != nil {
            NotificationCenter.default.post(name: NSNotification.Name.init("shortcut"), object: true)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name.init("shortcut"), object: true)
        completionHandler(true)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}
