//
//  iRetroAppApp.swift
//  iRetroApp
//
//  Created by Davide Andreoli on 01/05/24.
//

import SwiftUI
import SwiftData
import ArcadiaCore

#if os(macOS)
import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
#endif

@main
struct ArcadiaApp: App {
    
    @State private var showImportSheet: Bool = false
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    /*
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ArcadiaGame.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
*/
    var body: some Scene {
        @Bindable var fileManager = ArcadiaFileManager.shared
        WindowGroup {
            #if os(macOS)
            GameLibraryView()
                .handlesExternalEvents(preferring: Set(arrayLiteral: "*"), allowing: Set(arrayLiteral: "*"))
                .sheet(isPresented: $showImportSheet) {
                    ImportGameFromSheetView()
                }
                .onOpenURL { url in
                    ArcadiaNavigationState.shared.importedURL = url
                    showImportSheet.toggle()
                }
            #elseif os(iOS)
            TabView {
                GameLibraryView()
                    .tabItem {
                            Label("Game Systems", systemImage: "gamecontroller")
                        }
                DiscoverGameListView()
                    .tabItem {
                            Label("Featured Games", systemImage: "star")
                        }
                SettingsView()
                    .tabItem {
                                Label("Settings", systemImage: "gear")
                            }
            }
            .sheet(isPresented: $showImportSheet) {
                ImportGameFromSheetView()
            }
            .alert("Game loaded!", isPresented: $fileManager.showAlert) {
                Button("Ok", action: {})
            } message: {
                Text("You will find the game in the console's collection.")
            }
            .onOpenURL { url in
                //Probably need to copy it locally and use the local link?
                ArcadiaNavigationState.shared.importedURL = url
                showImportSheet.toggle()
            }
            #endif
                
        }
        #if os(macOS)
        .commands {
              CommandGroup(replacing: .newItem, addition: { })
           }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
        #endif
        //.modelContainer(sharedModelContainer)
        .environment(ArcadiaNavigationState.shared)
        .environment(ArcadiaFileManager.shared)
        .environment(ArcadiaCloudSyncManager.shared)
        .environment(ArcadiaCoreEmulationState.sharedInstance)
        .environment(InputController.shared)

        #if os(macOS)
        Settings {
            SettingsView()
                .environment(InputController.shared)
                .environment(ArcadiaFileManager.shared)
                .environment(ArcadiaCoreEmulationState.sharedInstance)
        }
        .windowResizability(.contentMinSize)
        Window("Featured Games", id: "featured-games") {
            DiscoverGameListView()
                .environment(ArcadiaNavigationState.shared)
                .environment(ArcadiaFileManager.shared)
        }
        #endif
    }
}
