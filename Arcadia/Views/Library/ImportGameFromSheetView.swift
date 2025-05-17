//
//  ImportGameFromSheetView.swift
//  Arcadia
//
//  Created by Davide Andreoli on 16/09/24.
//

import SwiftUI
import UniformTypeIdentifiers

enum ImportLoadingState {
    case systemSelection
    case loading
    case completedSuccessfully
}

struct ImportGameFromSheetView: View {
    
    @Environment(ArcadiaFileManager.self) var fileManager: ArcadiaFileManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedGameSystem: ArcadiaGameType?
    @State private var loadingState: ImportLoadingState = .systemSelection
    
    
    init() {
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if loadingState == .systemSelection {
                    Form {
                        Section {
                            Picker("Game console", selection: $selectedGameSystem) {
                                Text("No selection").tag(nil as ArcadiaGameType?)
                                ForEach(ArcadiaGameType.allCases, id: \.self) { gameSystem in
                                    if gameSystem.allowedExtensions.contains(UTType(filenameExtension: ArcadiaNavigationState.shared.importedURL?.pathExtension ?? "zzz")!) {
                                        Text(gameSystem.rawValue).tag(gameSystem as ArcadiaGameType?)
                                    }
                                }
                            }
                        } header: {
                            Text("Please pick a game system.")
                        } footer: {
                            Text("In some cases, multiple game systems will be compatible with your game file. Please make sure to select the correct one when importing.")
                        }
                        Section {
                            Button(action: {
                                withAnimation {
                                    loadingState = .loading
                                }
                                
                                if let gameSystem = selectedGameSystem, let gameURL = ArcadiaNavigationState.shared.importedURL {
                                    Task {
                                        await fileManager.saveGame(gameURL: gameURL, gameType: gameSystem)
                                    }
                                    withAnimation {
                                        loadingState = .completedSuccessfully
                                    }
                                }
                            }) {
                                Text("Import")
                            }
                            .disabled(selectedGameSystem == nil)
                            Button(role: .destructive, action: {
                                dismiss()
                            }) {
                                Text("Cancel")
                            }
                        }
                    }
                }
                if loadingState == .loading {
                    ProgressView() {
                        Label("Importing game", systemImage: "square.and.arrow.down")
                    }
                    .controlSize(.extraLarge)
                }
                if loadingState == .completedSuccessfully {
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.accentColor)
                        Text("Game loaded!")
                        Text("You will find the game in the console's collection.")
                        Button(role: .destructive, action: {
                            dismiss()
                        }) {
                            Text("Close")
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                    .padding()
                }
            }
            .navigationTitle("Import game")
            .toolbar() {
                ToolbarItem(placement: .automatic) {
                    Button(role: .cancel, action: {
                        dismiss()
                    }, label: {
                        Label("Dismiss", systemImage: "xmark")
                    })
                }
               
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

#Preview {
    ImportGameFromSheetView()
        .environment(ArcadiaFileManager.shared)
}
