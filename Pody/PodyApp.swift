//
//  PodyApp.swift
//  Pody
//
//  Created by cwr on 2023/6/22.
//

import SwiftUI

@main
struct PodyApp: App {
    @StateObject var myPlayer = MyPlayer()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(myPlayer)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
