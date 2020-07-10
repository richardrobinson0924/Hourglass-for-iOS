//
//  HourglassApp.swift
//  HourglassWatch Extension
//
//  Created by Richard Robinson on 2020-07-10.
//

import SwiftUI

@main
struct HourglassApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
