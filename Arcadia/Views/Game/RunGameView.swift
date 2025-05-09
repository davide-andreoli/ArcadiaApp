//
//  ContentView.swift
//  iRetroApp
//
//  Created by Davide Andreoli on 01/05/24.
//

import SwiftUI
import SwiftData
import ArcadiaCore
import AVFoundation

import GameController

#if os(macOS)
import AppKit
#else
import UIKit
#endif


struct RunGameView: View {
    @State private var gameURL: URL
    @State private var gameType: ArcadiaGameType
    @State private var toDismiss: Bool = false
    @State private var showWrongGameAlert: Bool = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @Environment(ArcadiaCoreEmulationState.self) var emulationState: ArcadiaCoreEmulationState
    @Environment(ArcadiaFileManager.self) var fileManager: ArcadiaFileManager
    @Environment(ArcadiaCloudSyncManager.self) var cloudSyncManager: ArcadiaCloudSyncManager
    @Environment(InputController.self) var inputController: InputController
    
    // iCloudSync being enabled is check already by the manager, but I keep it here as well to make the game view more efficient and avoid unnecessary calls if cloud sync is disabled
    @AppStorage("iCloudSyncEnabled") private var useiCloudSync = false
    @AppStorage("hideButtons") private var hideButtons = false
    @AppStorage("customizeGameViewBackgroundColor") private var customizeGameViewBackgroundColor: Bool = false
    @AppStorage("gameViewBackgroundColor") var gameViewBackgroundColor: Color = .black
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(gameURL: URL, gameType: ArcadiaGameType) {
        self.gameURL = gameURL
        self.gameType = gameType
    }

    var body: some View {
        @Bindable var emulationState = emulationState
        Group {
            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                //iPhone portrait
                ZStack {
                    if customizeGameViewBackgroundColor {
                        Rectangle()
                            .fill(gameViewBackgroundColor)
                            .ignoresSafeArea()
    
                    }
                    VStack {
                        CurrentBufferMetalView()
                            .frame(minWidth: CGFloat(emulationState.audioVideoInfo?.geometry.base_width ?? 0), minHeight: CGFloat(emulationState.audioVideoInfo?.geometry.base_height ?? 0))
                            .scaledToFit()
                        Spacer()
                        if !hideButtons {
                            ArcadiaButtonLayout(layoutElements: gameType.buttonLayoutElements)
                            
                        } else {
                            ArcadiaButtonOnlyLayout()
                        }

                    }
                }
            }
            else {
                ZStack {
                    if customizeGameViewBackgroundColor {
                        Rectangle()
                            .fill(gameViewBackgroundColor)
                            .ignoresSafeArea()
    
                    }
                    CurrentBufferMetalView()
                        .frame(minWidth: CGFloat(emulationState.audioVideoInfo?.geometry.base_width ?? 0), minHeight: CGFloat(emulationState.audioVideoInfo?.geometry.base_height ?? 0))
                        .scaledToFit()
                        //.layoutPriority(1)
                    //Spacer()
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            if !hideButtons {
                                ArcadiaButtonLayout(layoutElements: gameType.buttonLayoutElements)
                            } else {
                                ArcadiaButtonOnlyLayout()
                            }
                        }.frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                #if os(iOS)
                .ignoresSafeArea(.container, edges: .vertical)
                .persistentSystemOverlays(.hidden)
                #endif
            }
        }
        .onAppear(perform: {
            //inputController.loadGameConfiguration()
            //TODO: Invece del gameURL mandare uno struct con tutte le informazioni
            var stateURLs: [Int : URL] = [:]
            for i in 1...3 {
                stateURLs[i] = fileManager.getStateURL(gameURL: gameURL, gameType: gameType, slot: i)
            }
            var saveFIleURLs: [ArcadiaCoreMemoryType : URL] = [:]
            for memoryType in gameType.supportedSaveFiles.keys {
                saveFIleURLs[memoryType] = fileManager.getSaveURL(gameURL: gameURL, gameType: gameType, memoryType: memoryType)
            }
            emulationState.startEmulation(gameURL: gameURL, gameType: gameType, stateURLs: stateURLs, saveFileURLs: saveFIleURLs)
        })
        .onDisappear(perform: {
            //inputController.unloadGameConfiguration()
            emulationState.pauseEmulation()
            if useiCloudSync {
                for memoryType in gameType.supportedSaveFiles.keys {
                    cloudSyncManager.createCloudCopy(of: fileManager.getSaveURL(gameURL: gameURL, gameType: gameType, memoryType: memoryType))
                }
            }

        })
        .onChange(of: scenePhase) { oldValue, newValue in
            print(newValue)
            switch newValue {
            case .active:
                emulationState.resumeEmulation()
            case .background:
                emulationState.pauseEmulation()
                if useiCloudSync {
                    for memoryType in gameType.supportedSaveFiles.keys {
                        cloudSyncManager.createCloudCopy(of: fileManager.getSaveURL(gameURL: gameURL, gameType: gameType, memoryType: memoryType))
                    }
                }
                default:
                return
            }
            
        }
        .onReceive(timer) { _ in
            if useiCloudSync {
                for memoryType in gameType.supportedSaveFiles.keys {
                    cloudSyncManager.createCloudCopy(of: fileManager.getSaveURL(gameURL: gameURL, gameType: gameType, memoryType: memoryType))
                }
            }
        }
        .onChange(of: toDismiss) { oldValue, newValue in
            if newValue {
                dismiss()
            }
            
        }
        .onChange(of: emulationState.gameLoadingError) { oldValue, newValue in
            if newValue {
                showWrongGameAlert.toggle()
            }
            
        }
        .alert("Incorrect game loaded", isPresented: $showWrongGameAlert) {
            Button("Dismiss", action: { dismiss() })
        } message: {
            Text("It seems like you loaded an incompatible game file.")
        }
        .sheet(isPresented: $emulationState.showOverlay, content: {
            OverlayView(dismissMainView: $toDismiss)
        })
    #if os(iOS)
        .toolbar(.hidden, for: .tabBar)
    #endif

    }


}



#Preview {
    RunGameView(gameURL: URL(fileURLWithPath: "e"), gameType: .gameBoyGame)
}


