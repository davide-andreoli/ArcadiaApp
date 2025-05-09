//
//  iRetroFileManager.swift
//  iRetroApp
//
//  Created by Davide Andreoli on 07/05/24.
//

import Foundation
import UniformTypeIdentifiers
import ArcadiaCore
import SQLite3
import CryptoKit
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@Observable class ArcadiaFileManager {
    
    public static var shared = ArcadiaFileManager()
    public var currentGames: [URL] = []
    public var showAlert: Bool = false
    
    var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var libraryDirectory: URL {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    }
    
    var documentsMainDirectory: URL {
        return documentsDirectory
        
    }
        
    var libraryMainDirectory: URL {
        return libraryDirectory
    }
    
    var gamesDirectory: URL {
        return documentsMainDirectory.appendingPathComponent("Games")
    }
    

    
    var savesDirectory: URL {
        return documentsMainDirectory.appendingPathComponent("Saves")
    }
    
    var statesDirectory: URL {
        return documentsMainDirectory.appendingPathComponent("States")
    }

    var imagesDirectory: URL {
        return documentsMainDirectory.appendingPathComponent("Images")
    }

    var coresDirectory: URL {
        return documentsMainDirectory.appendingPathComponent("Cores")
    }
    
    var iCloudDocumentsDirectory: URL? {
            return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        }

    var iCloudDocumentsMainDirectory: URL? {
        return iCloudDocumentsDirectory
        }
    
    private init() {
        print("Init file manager")
        let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        
        let documentsMainDirectory = documentsMainDirectory
        var foldersToSync = [URL]()
        //TODO: Force the local and cloud only if available
        for dir in [gamesDirectory, savesDirectory, statesDirectory, imagesDirectory, coresDirectory] {
            do {
                if !FileManager.default.fileExists(atPath: dir.path) {
                    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
                }
                
                for gameSystem in ArcadiaGameType.allCases {
                    let gameSystemFolder = dir.appendingPathComponent(gameSystem.rawValue)
                    if !FileManager.default.fileExists(atPath: gameSystemFolder.path) {
                        try FileManager.default.createDirectory(at: gameSystemFolder, withIntermediateDirectories: true, attributes: nil)
                    }
                    foldersToSync.append(gameSystemFolder)
                }
                
            } catch {
                print("Error creating folder")
            }
        }
        
        for folder in foldersToSync {
            ArcadiaCloudSyncManager.shared.syncFolderToCloud(folder: folder)
        }

    }
    
    func getGamesURL(gameSystem: ArcadiaGameType) {
        do {
            let dir = try FileManager.default.contentsOfDirectory(at: self.gamesDirectory.appendingPathComponent(gameSystem.rawValue), includingPropertiesForKeys: nil)
            var correctFiles = [URL]()
            for fileToCheck in dir {
                if gameSystem.allowedExtensions.contains(UTType(filenameExtension: fileToCheck.pathExtension)!) {
                    correctFiles.append(fileToCheck)
                }
                
            }
            self.currentGames = correctFiles.sorted(by: {
                file1, file2 in
                return file1.deletingPathExtension().lastPathComponent.lowercased() <  file2.deletingPathExtension().lastPathComponent.lowercased()
            })
        }
        catch {
            self.currentGames = []
        }
    }
    
    func importSaveFile(for gameURL: URL, saveURL: URL, gameType: ArcadiaGameType, needScope: Bool = true) {
        if needScope {
            if gameURL.startAccessingSecurityScopedResource()  {
                defer {
                    gameURL.stopAccessingSecurityScopedResource()
                }
                
                let localSaveURL = getSaveURL(gameURL: gameURL, gameType: gameType)
                
                do {
                    let saveFile = try Data(contentsOf: saveURL)
                    try saveFile.write(to: localSaveURL, options: .atomic)
                    ArcadiaCloudSyncManager.shared.createCloudCopy(of: localSaveURL)
                } catch {
                    print("couldn't save file \(error)")
                }
            }
        }
    }
    
    func saveGame(gameURL: URL, gameType: ArcadiaGameType, fromSheet: Bool = false) {

            if gameURL.startAccessingSecurityScopedResource()  {
                print("entering the scoping")
                defer {
                    gameURL.stopAccessingSecurityScopedResource()
                }
                
                do {
                    
                    let romFile = try Data(contentsOf: gameURL)
                    print("Got Content")
                    let savePath = self.gamesDirectory.appendingPathComponent(gameType.rawValue).appendingPathComponent(gameURL.lastPathComponent)
                    try FileManager.default.createDirectory(at: self.gamesDirectory.appendingPathComponent(gameType.rawValue), withIntermediateDirectories: true)
                    try romFile.write(to: savePath, options: .atomic)
                    ArcadiaCloudSyncManager.shared.createCloudCopy(of: savePath)
                    
                    if let boxArtPath = getGameFromURL(gameURL: gameURL) {
                        guard let boxArtURL = URL(string: boxArtPath) else { return }
                        print("Got boxULR :\(boxArtURL)")
                        downloadAndProcessImage(of: gameURL, from: boxArtURL, gameType: gameType) { error in
                            DispatchQueue.main.async {
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                } else {
                                    print("Image saved successfully")
                                }
                            }
                        }
                    }
                    //To update the game list
                    getGamesURL(gameSystem: gameType)
                } catch {
                    print("couldn't save file \(error)")
                }
            }
            else {
                do {
                    
                    let romFile = try Data(contentsOf: gameURL)
                    print("Got Content")
                    let savePath = self.gamesDirectory.appendingPathComponent(gameType.rawValue).appendingPathComponent(gameURL.lastPathComponent)
                    try FileManager.default.createDirectory(at: self.gamesDirectory.appendingPathComponent(gameType.rawValue), withIntermediateDirectories: true)
                    try romFile.write(to: savePath, options: .atomic)
                    ArcadiaCloudSyncManager.shared.createCloudCopy(of: savePath)

                    if let boxArtPath = getGameFromURL(gameURL: gameURL) {
                        guard let boxArtURL = URL(string: boxArtPath) else { return }
                        print("Got boxULR :\(boxArtURL)")
                        downloadAndProcessImage(of: gameURL, from: boxArtURL, gameType: gameType) { error in
                            DispatchQueue.main.async {
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                } else {
                                    print("Image saved successfully")
                                }
                            }
                        }
                    }
                    //To update the game list
                    if let currentGameSystem = ArcadiaNavigationState.shared.currentGameSystem {
                        if currentGameSystem == gameType {
                            getGamesURL(gameSystem: gameType)
                        }
                    }
                } catch {
                    print("couldn't save file \(error)")
                }
            }
            
        if fromSheet {
            self.showAlert = true
        }

    }
    
    func importGameFromShare(gameURL : URL) {
        print(gameURL)
        let gameExtension = gameURL.pathExtension
        
        for gameType in ArcadiaGameType.allCases {
            if gameType.allowedExtensions.contains(UTType(filenameExtension: gameExtension)!) {
                self.saveGame(gameURL: gameURL, gameType: gameType)
                self.showAlert = true
            }
        }
    }
    
    func getSaveURL(gameURL: URL, gameType: ArcadiaGameType) -> URL {
        return self.savesDirectory.appendingPathComponent(gameType.rawValue).appendingPathComponent(gameURL.deletingPathExtension().lastPathComponent).appendingPathExtension(gameType.supportedSaveFiles[.memorySaveRam] ?? "srm")
    }
    
    
    func getSaveURL(gameURL: URL, gameType: ArcadiaGameType, memoryType: ArcadiaCoreMemoryType) -> URL {
            return self.savesDirectory.appendingPathComponent(gameType.rawValue).appendingPathComponent(gameURL.deletingPathExtension().lastPathComponent).appendingPathExtension(gameType.supportedSaveFiles[memoryType]!)
        
    }
    
    func getStateURL(gameURL: URL, gameType: ArcadiaGameType, slot: Int) -> URL {
            return self.statesDirectory.appendingPathComponent(gameType.rawValue).appendingPathComponent("\(gameURL.deletingPathExtension().lastPathComponent)_\(slot)").appendingPathExtension("state")
        
    }
    
    func getImageURL(gameURL: URL, gameType: ArcadiaGameType) -> URL {
            return self.imagesDirectory.appendingPathComponent(gameType.rawValue).appendingPathComponent(gameURL.deletingPathExtension().lastPathComponent).appendingPathExtension("jpg")
        
    }
    
    func getImageData(gameURL: URL, gameType: ArcadiaGameType) -> Data? {
        let fileURL = getImageURL(gameURL: gameURL, gameType: gameType)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let imageData = try Data(contentsOf: fileURL)
                return imageData
            } catch {
                print("Error loading image : \(error)")
            }
            return nil
        }
        return nil
    }
    
    func loadCustomImage(imageData: Data, gameURL: URL, gameType: ArcadiaGameType) {
        #if os(iOS)
        guard let image = UIImage(data: imageData) else {
            return
        }
        let resizedImage = resizeImage(image: image, toMaxDimension: 80)
        guard let resizedImageData = resizedImage.pngData() else {
            return
        }
        #elseif os(macOS)
        guard let image = NSImage(data: imageData) else {
            return
        }
        let resizedImage = resizeImage(image: image, toMaxDimension: 80)
        guard let resizedImageTiffData = resizedImage.tiffRepresentation else {
            return
        }
        let bitmapImageRep = NSBitmapImageRep(data: resizedImageTiffData)
        guard let resizedImageData = bitmapImageRep?.representation(using: .png, properties: [:]) else {
            return
        }
        #endif
        let imageURL = getImageURL(gameURL: gameURL, gameType: gameType)
        do {
            try resizedImageData.write(to: imageURL)
        }
        catch {
            print("Error saving image")
        }

    }
    
    func redownloadDefaultImage(gameURL: URL, gameType: ArcadiaGameType) {
        if let boxArtPath = getGameFromURL(gameURL: gameURL) {
            guard let boxArtURL = URL(string: boxArtPath) else { return }
            print("Got boxULR :\(boxArtURL)")
            downloadAndProcessImage(of: gameURL, from: boxArtURL, gameType: gameType) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        print("Image saved successfully")
                    }
                }
            }
        }
    }
    
    func deleteGame(gameURL: URL, gameType: ArcadiaGameType) {
        let imageURL = getImageURL(gameURL: gameURL, gameType: gameType)
        let saveURL = getSaveURL(gameURL: gameURL, gameType: gameType)
        let stateURL1 = getStateURL(gameURL: gameURL, gameType: gameType, slot: 1)
        let stateURL2 = getStateURL(gameURL: gameURL, gameType: gameType, slot: 2)
        let stateURL3 = getStateURL(gameURL: gameURL, gameType: gameType, slot: 3)
        
        for fileURL in [imageURL, saveURL, stateURL1, stateURL2, stateURL3] {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                    ArcadiaCloudSyncManager.shared.deleteCloudCopy(of: fileURL)
                } catch {
                    print("Could not delete")
                }
            }
        }
        
        if FileManager.default.fileExists(atPath: gameURL.path) {
            do {
                try FileManager.default.removeItem(atPath: gameURL.path)
                ArcadiaCloudSyncManager.shared.deleteCloudCopy(of: gameURL)
            } catch {
                print("Could not delete")
            }
        }
        //To update the list
        getGamesURL(gameSystem: gameType)
        
    }
    
    func deleteSaves(gameURL: URL, gameType: ArcadiaGameType) {
        let saveURL = getSaveURL(gameURL: gameURL, gameType: gameType)
        
        if FileManager.default.fileExists(atPath: saveURL.path) {
            do {
                try FileManager.default.removeItem(atPath: saveURL.path)
            } catch {
                print("Could not delete")
            }
        }

    }
    
    func deleteStates(gameURL: URL, gameType: ArcadiaGameType) {
        let stateURL1 = getStateURL(gameURL: gameURL, gameType: gameType, slot: 1)
        let stateURL2 = getStateURL(gameURL: gameURL, gameType: gameType, slot: 2)
        let stateURL3 = getStateURL(gameURL: gameURL, gameType: gameType, slot: 3)
        
        for stateURL in [stateURL1, stateURL2, stateURL3] {
            if FileManager.default.fileExists(atPath: stateURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: stateURL.path)
                } catch {
                    print("Could not delete")
                }
            }
        }

    }
    
    func clearSavesAndStates(gameURL: URL, gameType: ArcadiaGameType) {
        deleteSaves(gameURL: gameURL, gameType: gameType)
        deleteStates(gameURL: gameURL, gameType: gameType)

    }
    
    func renameGame(gameURL: URL, newName: String, gameType: ArcadiaGameType) {
        let imageURL = getImageURL(gameURL: gameURL, gameType: gameType)
        let saveURL = getSaveURL(gameURL: gameURL, gameType: gameType)
        let stateURL1 = getStateURL(gameURL: gameURL, gameType: gameType, slot: 1)
        let stateURL2 = getStateURL(gameURL: gameURL, gameType: gameType, slot: 2)
        let stateURL3 = getStateURL(gameURL: gameURL, gameType: gameType, slot: 3)
        
        let newGameURL = gameURL.deletingLastPathComponent().appendingPathComponent(newName).appendingPathExtension(gameURL.pathExtension)
        let newImageURL = getImageURL(gameURL: newGameURL, gameType: gameType)
        let newSaveURL = getSaveURL(gameURL: newGameURL, gameType: gameType)
        let newStateURL1 = getStateURL(gameURL: newGameURL, gameType: gameType, slot: 1)
        let newStateURL2 = getStateURL(gameURL: newGameURL, gameType: gameType, slot: 2)
        let newStateURL3 = getStateURL(gameURL: newGameURL, gameType: gameType, slot: 3)
        
        let fileURLs = [(imageURL, newImageURL), (saveURL, newSaveURL), (stateURL1, newStateURL1), (stateURL2, newStateURL2), (stateURL3, newStateURL3)]
        
        for (oldURL, newURL) in fileURLs {
            if FileManager.default.fileExists(atPath: oldURL.path) {
                do {
                    print("Renaming \(oldURL.lastPathComponent) to \(newURL.lastPathComponent)")
                    try FileManager.default.moveItem(at: oldURL, to: newURL)
                    
                    ArcadiaCloudSyncManager.shared.renameFileInCloud(file: oldURL, to: newURL)

                    
                } catch {
                    print("Could not rename \(oldURL.lastPathComponent) to \(newURL.lastPathComponent)")
                }
            }
        }
        
        if FileManager.default.fileExists(atPath: gameURL.path) {
            do {
                print("Renaming \(gameURL.lastPathComponent) to \(newGameURL.lastPathComponent)")
                try FileManager.default.moveItem(at: gameURL, to: newGameURL)
                ArcadiaCloudSyncManager.shared.renameFileInCloud(file: gameURL, to: newGameURL)

                
            } catch {
                print("Could not rename \(gameURL.lastPathComponent) to \(newGameURL.lastPathComponent)")
            }
        }
        

        // To update the list
        getGamesURL(gameSystem: gameType)
        
    }
    
    func md5Hash(from url: URL) -> String? {
        do {

            let data = try Data(contentsOf: url)
            let md5 = Insecure.MD5.hash(data: data)
            
            let md5String = md5.map { String(format: "%02hhx", $0) }.joined()
            
            return md5String.uppercased()
        } catch {
            print("Error reading data from URL: \(error)")
            return nil
        }
    }

    func openDatabase() -> OpaquePointer? {
        guard let fileURL = Bundle.main.url(forResource: "openvgdb", withExtension: "sqlite") else {
            print("Database file not found in bundle.")
            return nil
        }
        print("Database file path: \(fileURL.path)")
        
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            debugPrint("Cannot open DB. Error: \(String(cString: sqlite3_errmsg(db)))")
            return nil
        } else {
            print("DB successfully opened.")
            return db
        }
    }
    
    func gameMatchesDatabase(gameURL: URL) -> Bool {
        guard let db = openDatabase() else { return false }
        defer { sqlite3_close(db) }
        
        guard let gameHash = md5Hash(from: gameURL) else { return false }
        
        let queryStatementString = """
        SELECT *
        FROM ROMs
        WHERE ROMs.romHashMD5 = '\(gameHash)'
        LIMIT 1;
        """
        
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                return true
            }
            sqlite3_finalize(queryStatement)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Error preparing SELECT statement: \(errmsg)")
            return false
        }
        
        return false
        
    }
    
    func md5OfMatchingGame(gameURL: URL) -> String? {
        guard let db = openDatabase() else { return nil }
        defer { sqlite3_close(db) }
        
        guard let gameHash = md5Hash(from: gameURL) else { return nil }
        
        let queryStatementString = """
        SELECT *
        FROM ROMs
        WHERE ROMs.romHashMD5 = '\(gameHash)'
        LIMIT 1;
        """
        
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                return gameHash
            }
            sqlite3_finalize(queryStatement)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Error preparing SELECT statement: \(errmsg)")
            return nil
        }
        
        return nil
        
    }

    func getGameFromURL(gameURL: URL) -> String? {
           guard let db = openDatabase() else { return nil }
           defer { sqlite3_close(db) }
           
           guard let gameHash = md5Hash(from: gameURL) else { return nil }
           print("MD5 Hash: \(gameHash)")
           
           let queryStatementString = """
           SELECT releaseCoverFront
           FROM ROMs
           INNER JOIN RELEASES ON ROMs.romID = RELEASES.romID
           WHERE ROMs.romHashMD5 = '\(gameHash)'
           ORDER BY RELEASES.releaseDate DESC
           LIMIT 1;
           """
           print("SQL Query: \(queryStatementString)")
           
           var queryStatement: OpaquePointer? = nil
           var boxArtUrl: String? = nil
           
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                if let columnText = sqlite3_column_text(queryStatement, 0) {
                    boxArtUrl = String(cString: columnText)
                }
            }
            sqlite3_finalize(queryStatement)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Error preparing SELECT statement: \(errmsg)")
        }
           
           return boxArtUrl
       }
    
    
    func downloadAndProcessImage(of gameURL: URL, from imageURL: URL, gameType: ArcadiaGameType, completion: @escaping (Error?) -> Void) {
        
        print("Trying to download from \(imageURL)")
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                completion(error)
                return
            }
            
            print("Downloaded from \(imageURL)")
            guard let data = data else {
                completion(NSError(domain: "ImageProcessingError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            #if os(iOS)
            guard let image = UIImage(data: data) else {
                completion(NSError(domain: "ImageProcessingError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Unable to create image from data"]))
                return
            }
            #elseif os(macOS)
            guard let image = NSImage(data: data) else {
                completion(NSError(domain: "ImageProcessingError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Unable to create image from data"]))
                return
            }
            #endif
            
            let imageFileName = self.getImageURL(gameURL: gameURL, gameType: gameType)
            
            let resizedImage = self.resizeImage(image: image, toMaxDimension: 80)
            print("Resized image")
            
            #if os(iOS)
            guard let jpegData = resizedImage.jpegData(compressionQuality: 1.0) else {
                completion(NSError(domain: "ImageProcessingError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to JPEG"]))
                return
            }
            #elseif os(macOS)
            guard let tiffData = resizedImage.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else {
                completion(NSError(domain: "ImageProcessingError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to JPEG"]))
                return
            }
            #endif
            
            do {
                print("Writing to \(imageFileName)")
                try jpegData.write(to: imageFileName)
                ArcadiaCloudSyncManager.shared.createCloudCopy(of: imageFileName)
                completion(nil)
            } catch {
                completion(error)
            }
        }.resume()
    }

    #if os(iOS)
    func resizeImage(image: UIImage, toMaxDimension maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let widthRatio = maxDimension / size.width
        let heightRatio = maxDimension / size.height

        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    #elseif os(macOS)
    func resizeImage(image: NSImage, toMaxDimension maxDimension: CGFloat) -> NSImage {
        let size = image.size
        let widthRatio = maxDimension / size.width
        let heightRatio = maxDimension / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: NSRect(origin: .zero, size: size),
                   operation: .copy,
                   fraction: 1.0)
        resizedImage.unlockFocus()
        
        return resizedImage
    }
    #endif
    
    func getGameDirectory(for gameSystem: ArcadiaGameType) -> URL {
        return self.gamesDirectory.appendingPathComponent(gameSystem.rawValue)
    }
    
    func getSaveDirectory(for gameSystem: ArcadiaGameType) -> URL {
        return self.savesDirectory.appendingPathComponent(gameSystem.rawValue)
    }
    
    
    func getStateDirectory(for gameSystem: ArcadiaGameType) -> URL {
        return self.statesDirectory.appendingPathComponent(gameSystem.rawValue)
    }
    
    func getImageDirectory(for gameSystem: ArcadiaGameType) -> URL {
        return self.imagesDirectory.appendingPathComponent(gameSystem.rawValue)
    }
    
    func getCoreDirectory(for gameSystem: ArcadiaGameType) -> URL {
        return self.coresDirectory.appendingPathComponent(gameSystem.rawValue)
    }
                    
    func uploadFilesToiCloud() {
        var localURLs = [URL]()
        for gameSystem in ArcadiaGameType.allCases {
            localURLs.append(getGameDirectory(for: gameSystem))
            localURLs.append(getSaveDirectory(for: gameSystem))
            localURLs.append(getStateDirectory(for: gameSystem))
            localURLs.append(getImageDirectory(for: gameSystem))
            localURLs.append(getCoreDirectory(for: gameSystem))
        }

        uploadFilesToiCloud(in: localURLs)
        
    }
    
    func uploadFilesToiCloud(in folders: [URL]) {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }

        for localURL in folders {
            let iCloudSubDirectory = iCloudURL
                .appendingPathComponent(localURL.pathComponents[localURL.pathComponents.index(localURL.pathComponents.endIndex, offsetBy: -2)])
                .appendingPathComponent(localURL.lastPathComponent)

            do {
                try FileManager.default.createDirectory(at: iCloudSubDirectory, withIntermediateDirectories: true, attributes: nil)

                let localContents = try FileManager.default.contentsOfDirectory(at: localURL, includingPropertiesForKeys: [.contentModificationDateKey])
                let iCloudContents = try FileManager.default.contentsOfDirectory(at: iCloudSubDirectory, includingPropertiesForKeys: [.contentModificationDateKey])

                // Create a dictionary of iCloud files
                var iCloudFilesDict = [String: URL]()
                for iCloudFile in iCloudContents {
                    iCloudFilesDict[iCloudFile.lastPathComponent] = iCloudFile
                }

                // Sync local files to iCloud
                for localFile in localContents {
                    let iCloudFile = iCloudSubDirectory.appendingPathComponent(localFile.lastPathComponent)

                    if let iCloudFile = iCloudFilesDict[localFile.lastPathComponent] {
                        // Compare modification dates
                        let localAttributes = try FileManager.default.attributesOfItem(atPath: localFile.path)
                        let iCloudAttributes = try FileManager.default.attributesOfItem(atPath: iCloudFile.path)

                        if let localDate = localAttributes[.modificationDate] as? Date,
                           let iCloudDate = iCloudAttributes[.modificationDate] as? Date {
                            if localDate > iCloudDate {
                                // Local file is more recent, copy to iCloud
                                print("Copying local file to iCloud \(iCloudFile)")
                                try FileManager.default.removeItem(at: iCloudFile)
                                try FileManager.default.copyItem(at: localFile, to: iCloudFile)
                            }
                        }
                    } else {
                        // iCloud file doesn't exist, copy local file to iCloud
                        print("Copying local file to iCloud \(iCloudFile)")
                        try FileManager.default.copyItem(at: localFile, to: iCloudFile)
                    }
                }
            } catch {
                print("Error syncing data to iCloud: \(error)")
            }
        }
    }
    
    func downloadDataFromiCloud() {
        var localURLs = [URL]()
        for gameSystem in ArcadiaGameType.allCases {
            localURLs.append(getGameDirectory(for: gameSystem))
            localURLs.append(getSaveDirectory(for: gameSystem))
            localURLs.append(getStateDirectory(for: gameSystem))
            localURLs.append(getImageDirectory(for: gameSystem))
            localURLs.append(getCoreDirectory(for: gameSystem))
        }

        downloadDataFromiCloud(in: localURLs)
        
    }
    
    func downloadDataFromiCloud(in folders: [URL]) {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }

        for localURL in folders {
            let iCloudSubDirectory = iCloudURL
                .appendingPathComponent(localURL.pathComponents[localURL.pathComponents.index(localURL.pathComponents.endIndex, offsetBy: -2)])
                .appendingPathComponent(localURL.lastPathComponent)

            do {
                try FileManager.default.createDirectory(at: localURL, withIntermediateDirectories: true, attributes: nil)

                let localContents = try FileManager.default.contentsOfDirectory(at: localURL, includingPropertiesForKeys: [.contentModificationDateKey])
                let iCloudContents = try FileManager.default.contentsOfDirectory(at: iCloudSubDirectory, includingPropertiesForKeys: [.contentModificationDateKey])

                // Create a dictionary of local files
                var localFilesDict = [String: URL]()
                for localFile in localContents {
                    localFilesDict[localFile.lastPathComponent] = localFile
                }

                // Sync iCloud files to local
                for iCloudFile in iCloudContents {
                    let localFile = localURL.appendingPathComponent(iCloudFile.lastPathComponent)

                    if let localFile = localFilesDict[iCloudFile.lastPathComponent] {
                        // Compare modification dates
                        let localAttributes = try FileManager.default.attributesOfItem(atPath: localFile.path)
                        let iCloudAttributes = try FileManager.default.attributesOfItem(atPath: iCloudFile.path)

                        if let localDate = localAttributes[.modificationDate] as? Date,
                           let iCloudDate = iCloudAttributes[.modificationDate] as? Date {
                            if iCloudDate > localDate {
                                // iCloud file is more recent, copy to local
                                print("Copying iCloud file to local \(localFile)")
                                try FileManager.default.removeItem(at: localFile)
                                try FileManager.default.copyItem(at: iCloudFile, to: localFile)
                            }
                        }
                    } else {
                        // Local file doesn't exist, copy iCloud file to local
                        print("Copying iCloud file to local \(localFile)")
                        try FileManager.default.copyItem(at: iCloudFile, to: localFile)
                    }
                }
            } catch {
                print("Error syncing data from iCloud: \(error)")
            }
        }
    }
    
    func syncDataToiCloud() {
        var localURLs = [URL]()
        for gameSystem in ArcadiaGameType.allCases {
            localURLs.append(getGameDirectory(for: gameSystem))
            localURLs.append(getSaveDirectory(for: gameSystem))
            localURLs.append(getStateDirectory(for: gameSystem))
            localURLs.append(getImageDirectory(for: gameSystem))
            localURLs.append(getCoreDirectory(for: gameSystem))
        }

        syncDataToiCloud(in: localURLs)
        
    }


            
    func syncDataToiCloud(in folders: [URL]) {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }
        
        let localURLs = folders
        for localURL in localURLs {
            let iCloudSubDirectory = iCloudURL
                .appendingPathComponent(localURL.pathComponents[localURL.pathComponents.index(localURL.pathComponents.endIndex, offsetBy: -2)])
                .appendingPathComponent(localURL.lastPathComponent)
            do {
                try FileManager.default.createDirectory(at: iCloudSubDirectory, withIntermediateDirectories: true, attributes: nil)
  
                let localContents = try FileManager.default.contentsOfDirectory(at: localURL, includingPropertiesForKeys: [.contentModificationDateKey])
                let iCloudContents = try FileManager.default.contentsOfDirectory(at: iCloudSubDirectory, includingPropertiesForKeys: [.contentModificationDateKey])
                
                // Create a dictionary of local files
                var localFilesDict = [String: URL]()
                for localFile in localContents {
                    localFilesDict[localFile.lastPathComponent] = localFile
                }

                // Create a dictionary of iCloud files
                var iCloudFilesDict = [String: URL]()
                for iCloudFile in iCloudContents {
                    iCloudFilesDict[iCloudFile.lastPathComponent] = iCloudFile
                }

                // Sync files
                for localFile in localContents {
                    let iCloudFile = iCloudSubDirectory.appendingPathComponent(localFile.lastPathComponent)
               
                    if let iCloudFile = iCloudFilesDict[localFile.lastPathComponent] {
                        // Compare modification dates
                        let localAttributes = try FileManager.default.attributesOfItem(atPath: localFile.path)
                        let iCloudAttributes = try FileManager.default.attributesOfItem(atPath: iCloudFile.path)
                        
                        if let localDate = localAttributes[.modificationDate] as? Date,
                           let iCloudDate = iCloudAttributes[.modificationDate] as? Date {
                            if localDate > iCloudDate {
                                // Local file is more recent, copy to iCloud
                                print("Copying local file to iCloud \(iCloudFile)")
                                try FileManager.default.removeItem(at: iCloudFile)
                                try FileManager.default.copyItem(at: localFile, to: iCloudFile)
                            } else if iCloudDate > localDate {
                                // iCloud file is more recent, copy to local
                                print("Copying iCloud file to local \(iCloudFile)")
                                try FileManager.default.removeItem(at: localFile)
                                try FileManager.default.copyItem(at: iCloudFile, to: localFile)
                            }
                        }
                    } else {
                        // iCloud file doesn't exist, copy local file to iCloud
                            //print("Copying local file to iCloud \(iCloudFile)")
                            //try FileManager.default.copyItem(at: localFile, to: iCloudFile)

                    }
                }

                // Copy files from iCloud to local if they don't exist locally
                for iCloudFile in iCloudContents {
                    if localFilesDict[iCloudFile.lastPathComponent] == nil {
                        let localFile = localURL.appendingPathComponent(iCloudFile.lastPathComponent)
                        print("Copying iCloud file to local \(localFile)")
                        try FileManager.default.copyItem(at: iCloudFile, to: localFile)
                    }
                }
                
                
                // Delete local files that do not exist in iCloud
                for localFile in localContents {
                    if iCloudFilesDict[localFile.lastPathComponent] == nil {
                        print("Deleting local file \(localFile.lastPathComponent) because it doesn't exist in iCloud")
                        try FileManager.default.removeItem(at: localFile)
                    }
                }
                
            } catch {
                print("Error syncing data to iCloud: \(error)")
            }
        }
    }
    
    func deleteCloudCopy(of file: URL) {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let iCloudFileURL = iCloudURL.appendingPathComponent(file.pathComponents[file.pathComponents.index(file.pathComponents.endIndex, offsetBy: -3)]).appendingPathComponent(file.pathComponents[file.pathComponents.index(file.pathComponents.endIndex, offsetBy: -2)]).appendingPathComponent(file.lastPathComponent)
            print(iCloudFileURL)
            
            if FileManager.default.fileExists(atPath: iCloudFileURL.path) {
                do {
                    try FileManager.default.removeItem(at: iCloudFileURL)
                } catch {
                    print("Could not delete")
                }
            }
        }
        
        
    }
    
    func createCloudCopy(of file: URL) {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if !FileManager.default.fileExists(atPath: file.path) {
                return
            }
            
            let iCloudSubDirectory = iCloudURL.appendingPathComponent(file.pathComponents[file.pathComponents.index(file.pathComponents.endIndex, offsetBy: -3)]).appendingPathComponent(file.pathComponents[file.pathComponents.index(file.pathComponents.endIndex, offsetBy: -2)])
            
            let iCloudFileURL = iCloudURL.appendingPathComponent(file.pathComponents[file.pathComponents.index(file.pathComponents.endIndex, offsetBy: -3)]).appendingPathComponent(file.pathComponents[file.pathComponents.index(file.pathComponents.endIndex, offsetBy: -2)]).appendingPathComponent(file.lastPathComponent)
            
            
            do {
                try FileManager.default.createDirectory(at: iCloudSubDirectory, withIntermediateDirectories: true, attributes: nil)
                
                if FileManager.default.fileExists(atPath: iCloudFileURL.path) {
                    let localAttributes = try FileManager.default.attributesOfItem(atPath: file.path)
                    let iCloudAttributes = try FileManager.default.attributesOfItem(atPath: iCloudFileURL.path)
                    
                    if let localDate = localAttributes[.modificationDate] as? Date,
                       let iCloudDate = iCloudAttributes[.modificationDate] as? Date {
                        if iCloudDate > localDate {
                            print("Local file is less recent, skipping")
                            return
                        } else {
                            try FileManager.default.removeItem(at: iCloudFileURL)
                        }
                    }
                }
                try FileManager.default.copyItem(at: file, to: iCloudFileURL)
            } catch {
                print("Could not copy \(error)")
            }
        }

    }
    
    func renameCloudCopy(of file: URL, to newFile: URL) {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
                                    
            let iCloudOldFileURL = iCloudURL.appendingPathComponent(file.pathComponents[file.pathComponents.index(file.pathComponents.endIndex, offsetBy: -3)]).appendingPathComponent(file.pathComponents[file.pathComponents.index(file.pathComponents.endIndex, offsetBy: -2)]).appendingPathComponent(file.lastPathComponent)
            
            let iCloudNewFileURL = iCloudURL.appendingPathComponent(file.pathComponents[file.pathComponents.index(file.pathComponents.endIndex, offsetBy: -3)]).appendingPathComponent(file.pathComponents[file.pathComponents.index(file.pathComponents.endIndex, offsetBy: -2)]).appendingPathComponent(newFile.lastPathComponent)
            
            if !FileManager.default.fileExists(atPath: iCloudOldFileURL.path) {
                return
            }
            
            do {
                print("Cloud renaming \(iCloudOldFileURL.lastPathComponent) to \(iCloudNewFileURL.lastPathComponent)")
                try FileManager.default.moveItem(at: iCloudOldFileURL, to: iCloudNewFileURL)
                
            } catch {
                print("Could not rename \(error)")
            }
        }
        
    }
    

    
}
