//
//  CoreInfoView.swift
//  Arcadia
//
//  Created by Davide Andreoli on 29/09/24.
//

import SwiftUI

struct CoreInfoView: View {
    
    @State private var gameType: ArcadiaGameType
    @Environment(\.dismiss) var dismiss
    
    init(gameType: ArcadiaGameType) {
        self.gameType = gameType
    }
    
    var body: some View {
        NavigationStack {
            List {
                gameType.coreSpecificInfo
                
                Section(header: Text("Allowed extensions"), footer: Text("This console can load files with any of the above extension.")) {
                    ForEach(gameType.allowedExtensions, id: \.self) { allowedExtension in
                        Text(".\(allowedExtension.tags[.filenameExtension]?.joined(separator: "") ?? "NIL")")
                    }
                }
                
                Section(header: Text("Console's folders"), footer: Text("Use these links to access the folders where this console stores files.")) {
                    Button(action: {
                        #if os(macOS)
                        NSWorkspace.shared.open(gameType.getGameDirectory)
                        #elseif os(iOS)
                        let path = gameType.getGameDirectory.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                        UIApplication.shared.open(URL(string: path)!)
                        #endif
                    }) {
                        Text("Open games directory")
                    }
                    Button(action: {
                        #if os(macOS)
                        NSWorkspace.shared.open(gameType.getSaveDirectory)
                        #elseif os(iOS)
                        let path = gameType.getSaveDirectory.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                        UIApplication.shared.open(URL(string: path)!)
                        #endif
                    }) {
                        Text("Open saves directory")
                    }
                    Button(action: {
                        #if os(macOS)
                        NSWorkspace.shared.open(gameType.getStateDirectory)
                        #elseif os(iOS)
                        let path = gameType.getStateDirectory.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                        UIApplication.shared.open(URL(string: path)!)
                        #endif
                    }) {
                        Text("Open states directory")
                    }
                    Button(action: {
                        #if os(macOS)
                        NSWorkspace.shared.open(gameType.getImageDirectory)
                        #elseif os(iOS)
                        let path = gameType.getImageDirectory.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                        UIApplication.shared.open(URL(string: path)!)
                        #endif
                    }) {
                        Text("Open images directory")
                    }
                    Button(action: {
                        #if os(macOS)
                        NSWorkspace.shared.open(gameType.getCoreDirectory)
                        #elseif os(iOS)
                        let path = gameType.getCoreDirectory.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                        UIApplication.shared.open(URL(string: path)!)
                        #endif
                    }) {
                        Text("Open core files directory")
                    }
                }
            }
            .navigationTitle(gameType.name)
            .frame(minWidth: 300, minHeight: 300)
            .toolbar() {
                ToolbarItem(placement: .automatic) {
                    Button(role: .cancel, action: {
                        dismiss()
                    }, label: {
                        Label("Dismiss", systemImage: "xmark")
                    })
                }
               
            }
        }
    }
}

#Preview {
    CoreInfoView(gameType: .snesGame)
}
