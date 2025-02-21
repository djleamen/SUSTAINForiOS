//
//  SUSTAINForiOSApp.swift
//  SUSTAINForiOS
//
//  Created by klein cafa on 2025-02-18.
//

import SwiftUI
import os

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    return true
  }
}

@main
struct SUSTAINForiOSApp: App {
    // Configure logging
    private let logger = Logger(subsystem: "com.sustain", category: "Logging")
    
    init() {
        startLogging() // Start logging
    }
    
    func startLogging() {
        logger.info("SUSTAINForiOS app started")
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
