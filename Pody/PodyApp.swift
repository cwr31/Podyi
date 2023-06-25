//
//  PodyApp.swift
//  Pody
//
//  Created by cwr on 2023/6/22.
//

import SwiftUI

@main
struct PodyApp: App {
    @StateObject var playerService = PlayerService()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerService)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
