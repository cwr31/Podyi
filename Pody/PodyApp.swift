//
//  PodyApp.swift
//  Pody
//
//  Created by cwr on 2023/6/22.
//

import PodcastIndexKit
import SwiftUI

@main
struct PodyApp: App {
//    @StateObject var playerViewModel = PlayerViewModel()
//    @StateObject var router = Router()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PlayerViewModel())
                .environmentObject(Router())
                .environmentObject(PodcastIndexService())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
