//
//  HourglassApp.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import SwiftUI

@main
struct HourglassApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(model: Model.shared).padding(.horizontal, 16)
        }
    }
}
