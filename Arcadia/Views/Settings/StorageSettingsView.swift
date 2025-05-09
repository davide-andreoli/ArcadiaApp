//
//  SynchronizationSettingsView.swift
//  Arcadia
//
//  Created by Davide Andreoli on 09/07/24.
//

import SwiftUI

struct StorageSettingsView: View {
    
    @State private var showOverlay = false
    
    @AppStorage("iCloudSyncEnabled") private var useiCloudSync = false
    @Environment(ArcadiaFileManager.self) var fileManager: ArcadiaFileManager
    @Environment(ArcadiaCloudSyncManager.self) var cloudSyncManager: ArcadiaCloudSyncManager
    
    
    var body: some View {
        
        Form {
            Section {
                Toggle(isOn: $useiCloudSync) {
                    Label("Sync data to iCloud", systemImage: "cloud")
                }
                .onChange(of: useiCloudSync) { oldValue, newValue in
                    if newValue {
                        showOverlay = true
                        cloudSyncManager.uploadFilesToiCloud()
                        showOverlay = false
                    } else {
                        showOverlay = true
                        cloudSyncManager.downloadDataFromiCloud()
                        showOverlay = false
                    }
                }
                if useiCloudSync {
                    Text("\(cloudSyncManager.lastSyncStatus.textToShow)")
                }
                Button(action : {
                    cloudSyncManager.syncDataToiCloud()
                }) {
                    Text("Force sync")
                }
                .disabled(!useiCloudSync)
            }
            Section {
                Button(action: {
                    #if os(macOS)
                    NSWorkspace.shared.open( fileManager.documentsMainDirectory)
                    #elseif os(iOS)
                    let path = fileManager.documentsMainDirectory.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                    UIApplication.shared.open(URL(string: path)!)
                    #endif
                }) {
                    Text("Open storage directory")
                }
            }
        }
        .overlay {
            Group {
                if showOverlay {
                    ZStack {
                        Rectangle()
                            .fill(.background)
                            .opacity(0.5)
                        VStack {
                            Text("Copying data to iCloud folder")
                            ProgressView()
                        }
                    }
                }
            }
        }
        .navigationTitle("Storage")
    }
}

#Preview {
    StorageSettingsView()
        .environment(ArcadiaFileManager.shared)
}
