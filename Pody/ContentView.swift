//
//  ContentView.swift
//  Pody
//
//  Created by cwr on 2023/6/22.
//

import CoreData
import SwiftUI

struct ContentView: View {
//    @State var tabSelection: Int = 0
    @State var tabSelection: Tabs = .home
    @EnvironmentObject private var router: Router
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            TabView(selection: $tabSelection) {
                NavigationLink (destination: PlayerView()){
                    Text("Tap me")
                }
                .navigationBarTitle("Home")
                .tabItem {
                    Label("Sons", systemImage: "speaker.wave.3.fill")
                }
                .tag(0)
                
                Test()
                
                    .tabItem {
                        Label("Sons", systemImage: "music.quarternote.3")
                    }
                    .tag(1)
                
                
                Text("2")
                
                    .tabItem {
                        Label("Sons", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(2)
            }
            .navigationViewStyle(.stack)
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(PlayerViewModel())
    }
}
