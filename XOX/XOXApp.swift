//
//  XOXApp.swift
//  XOX
//
//  Created by Dexter Ramos on 10/9/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        RemoteConfigManager.shared.configure()
        return true
    }
}


@main
struct XOXApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modifier(SpecialNavbar())
        }
    }
}
