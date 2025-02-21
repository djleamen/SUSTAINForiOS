//
//  SUSTAINForiOSApp.swift
//  SUSTAINForiOS
//
//  Created by klein cafa on 2025-02-18.
//

import SwiftUI
import os

@main
struct SUSTAINForiOSApp: App {
    private let logger = Logger(subsystem: "com.sustain", category: "Logging")

    init() {
        startLogging()
    }
    
    func startLogging() {
        logger.info("SUSTAINForiOS app started")
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()  // ✅ Uses ContentView
            }
        }
    }
}
