//
//  GameIconView.swift
//  iRetroApp
//
//  Created by Davide Andreoli on 08/05/24.
//

import SwiftUI
import PhotosUI

struct GameRowView: View {
    
    @State private var gameTitle: String
    private var gameType: ArcadiaGameType
    private var gameURL: URL
    @State private var exportedFileURL: URL
    @Environment(ArcadiaFileManager.self) var fileManager: ArcadiaFileManager
    @State private var imageData: Data?
    @State private var showingRenameAlert = false
    @State private var showingChangeImage = false
    @State private var showingSaveExporter = false
    @State private var showingSaveImporter = false
    @State private var exportingSave = false
    @State private var showingGameExporter = false
    @State private var newGameName: String = ""
    @State private var selectedCustomImage: PhotosPickerItem?
    
    init(gameTitle: String, gameURL: URL, gameType: ArcadiaGameType) {
        self.gameTitle = gameTitle
        self.gameType = gameType
        self.gameURL = gameURL
        self.exportedFileURL = gameURL
    }
    
    var body: some View {
        let saveURL = fileManager.getSaveURL(gameURL: gameURL, gameType: gameType)
        HStack {
            if let image = imageData {
                #if os(macOS)
                Image(nsImage: NSImage(data: image)!)
                    .frame(width: 80, height: 80)
                #else
                Image(uiImage: UIImage(data: image)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                #endif
            } else {
                ZStack {
                    gameType.defaultCollectionImage
                }
                .frame(width: 80, height: 80)
            }

            Text(gameTitle)
                .font(.headline)
            Spacer()
            Image(systemName: FileManager.default.fileExists(atPath: saveURL.path) ? "bookmark.circle.fill" : "bookmark.circle")
        }
        .onAppear {
            imageData = fileManager.getImageData(gameURL: gameURL, gameType: gameType)
            //TODO: Find a more robust way to load the cover after the game has been loaded
            /*
            if imageData == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    imageData = fileManager.getImageData(gameURL: gameURL, gameType: gameType)
                }
            }
             */
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                Task {
                    await fileManager.deleteGame(gameURL: gameURL, gameType: gameType)
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
            Button {
                showingRenameAlert.toggle()
            } label: {
                Label("Rename", systemImage: "square.and.pencil")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(role: .destructive) {
                fileManager.clearSavesAndStates(gameURL: gameURL, gameType: gameType)
            } label: {
                Label("Clear saves and states", systemImage: "clear")
            }
            Button {
                showingChangeImage.toggle()
            } label: {
                Label("Change image", systemImage: "photo.artframe")
            }
        }
        .contextMenu(menuItems: {
            Button(role: .destructive) {
                Task {
                    await fileManager.deleteGame(gameURL: gameURL, gameType: gameType)
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
            Button {
                showingRenameAlert.toggle()
                newGameName = gameURL.deletingPathExtension().lastPathComponent
            } label: {
                Label("Rename", systemImage: "square.and.pencil")
            }
            Button(role: .destructive) {
                fileManager.clearSavesAndStates(gameURL: gameURL, gameType: gameType)
            } label: {
                Label("Clear saves and states", systemImage: "clear")
            }
            if FileManager.default.fileExists(atPath: saveURL.path) {
                Button {
                    showingSaveExporter.toggle()
                } label: {
                    Label("Export save", systemImage: "square.and.arrow.up")
                }
            }
            ShareLink(item: gameURL) {
                Label("Share game", systemImage: "square.and.arrow.up")
            }
            Button {
                showingChangeImage.toggle()
            } label: {
                Label("Change image", systemImage: "photo.artframe")
            }
            Button {
                Task {
                    await fileManager.redownloadDefaultImage(gameURL: gameURL, gameType: gameType)
                }
            } label: {
                Label("Redownload default image", systemImage: "arrow.2.squarepath")
            }
        })
        .alert("Enter the new name", isPresented: $showingRenameAlert) {
            TextField("Enter the new game name", text: $newGameName)
            Button("Confirm", action: {
                Task {
                    await fileManager.renameGame(gameURL: gameURL, newName: newGameName, gameType: gameType)
                    newGameName = ""
                }
                
            })
            Button("Cancel", role: .cancel) {
                newGameName = ""
            }
        } message: {
            Text("Enter the new name for the game.")
        }
        .photosPicker(isPresented: $showingChangeImage, selection: $selectedCustomImage, matching: .images)
        .task(id: selectedCustomImage) {
            let imageData = try? await selectedCustomImage?.loadTransferable(type: Data.self)
            guard let loadedImage = imageData else {
                return
            }
            fileManager.loadCustomImage(imageData: loadedImage, gameURL: gameURL, gameType: gameType)
            self.imageData = fileManager.getImageData(gameURL: gameURL, gameType: gameType)
        }
        /*
        .fileImporter(isPresented: $showingSaveImporter, allowedContentTypes: [UTType.data], onCompletion: { result in
            DispatchQueue.global(qos: .userInteractive).async {
                switch result {
                case .success(let saveURL):
                    fileManager.importSaveFile(for: gameURL, saveURL: saveURL, gameType: gameType)
                case .failure(let error):
                    print("error reading: \(error.localizedDescription)")
                }

                
            }
        })
         */
        .fileExporter(isPresented: $showingSaveExporter, document: ArcadiaSaveFile(fileURL: saveURL), contentType: UTType(importedAs: "com.davideandreoli.Arcadia.saveFile"), defaultFilename: saveURL.lastPathComponent) {
            result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        
    }
}

#Preview {
    GameRowView(gameTitle: "Pokemon - Versione Cristallo", gameURL: URL(string: "file://path.it")!, gameType: .gameBoyGame)
        .environment(ArcadiaFileManager.shared)
}
