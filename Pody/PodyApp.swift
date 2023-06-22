//
//  PodyApp.swift
//  Pody
//
//  Created by cwr on 2023/6/22.
//

import SwiftUI

@main
struct PodyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
