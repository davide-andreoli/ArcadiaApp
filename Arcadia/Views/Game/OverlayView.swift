//
//  OverlayView.swift
//  Arcadia
//
//  Created by Davide Andreoli on 25/05/24.
//

import SwiftUI
import ArcadiaCore

struct OverlayView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentSelection: String = ""
    @State private var stateSlot: Int = 1
    @Binding var dismissMainView: Bool
    @Environment(InputController.self) var inputController: InputController
    @Environment(ArcadiaFileManager.self) var fileManager: ArcadiaFileManager
    @Environment(ArcadiaCoreEmulationState.self) var emulationState: ArcadiaCoreEmulationState
    @Environment(ArcadiaCloudSyncManager.self) var cloudSyncManager: ArcadiaCloudSyncManager
    
    init(dismissMainView: Binding<Bool>) {
        self._dismissMainView = dismissMainView
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Save states")) {
                    Picker("", selection: $stateSlot) {
                        ForEach(Array([1,2,3]), id: \.self) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                        Button(
                            action: {
                                ArcadiaCoreEmulationState.sharedInstance.currentCore?.saveState(saveFileURL: ArcadiaCoreEmulationState.sharedInstance.currentStateURL[stateSlot]!)
                                    cloudSyncManager.createCloudCopy(of: ArcadiaCoreEmulationState.sharedInstance.currentStateURL[stateSlot]!)
                                dismiss()
                            }) {
                            Text("Save State")
                        }
                        Button(
                            action: {
                                ArcadiaCoreEmulationState.sharedInstance.currentCore?.loadState(saveFileURL: ArcadiaCoreEmulationState.sharedInstance.currentStateURL[stateSlot]!)
                                dismiss()
                            }) {
                            Text("Load State")
                        }
                            .disabled(
                                !FileManager.default.fileExists(atPath: ArcadiaCoreEmulationState.sharedInstance.currentStateURL[stateSlot]!.path)
                            )
                    }
                
                PlayerSelectionView()
                Section {
                    //emulationState.lastImage
                    if let lastFrame = emulationState.currentFrame {
                        let renderer = ImageRenderer(content: AttribitedScreenshotView(screenshotImage: lastFrame))
                        #if os(iOS)
                        if let uiImage = renderer.uiImage {
                            let image = Image(uiImage: uiImage)
                            ShareLink(item: image, preview: SharePreview("", image: image)) {
                                Label("Share on social media", systemImage: "square.and.arrow.up")
                            }
                        }
                        if let cgImage = emulationState.currentFrame {
                            let uiImage = UIImage(cgImage: cgImage)
                            let image = Image(uiImage: uiImage)
                            ShareLink(item: image, preview: SharePreview("", image: image)) {
                                Label("Save screenshot", systemImage: "square.and.arrow.down")
                            }
                        }
                        #elseif os(macOS)
                        if let nsImage = renderer.nsImage {
                            let image = Image(nsImage: nsImage)
                            ShareLink(item: image, preview: SharePreview("", image: image)) {
                                Label("Share on social media", systemImage: "square.and.arrow.up")
                            }
                        }
                        if let cgImage = emulationState.currentFrame {
                            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                            let image = Image(nsImage: nsImage)
                            ShareLink(item: image, preview: SharePreview("", image: image)) {
                                Label("Save screenshot", systemImage: "square.and.arrow.down")
                            }
                        }
                        #endif
                    } else {
                        Text("There was an issue in loading the screenshot feature")
                    }
                }
                Section {
                    
                }

            }
            .padding()
            .navigationTitle("Overlay")
            .toolbar() {
                ToolbarItem(placement: .automatic) {
                    Button(role: .cancel, action: {
                        dismiss()
                    }, label: {
                        Label("Dismiss", systemImage: "xmark")
                    })
                }
               
            }
            .onAppear {
                //inputController.unloadGameConfiguration()
            }
            .onDisappear {
                //inputController.loadGameConfiguration()
                ArcadiaCoreEmulationState.sharedInstance.resumeEmulation()
            }
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}


#Preview {
    OverlayView(dismissMainView: .constant(false))
}

