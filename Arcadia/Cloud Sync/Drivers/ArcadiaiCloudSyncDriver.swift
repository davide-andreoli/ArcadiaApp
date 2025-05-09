//
//  ArcadiaiCloudSyncDriver.swift
//  Arcadia
//
//  Created by Davide Andreoli on 09/05/25.
//

import Foundation

enum ArcadiaCloudSyncError: Error {
    case error
}

struct ArcadiaiCloudSyncDriver: ArcadiaSyncDriverProtocol {
    
    var iCloudDocumentsDirectory: URL? {
            return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        }

    var iCloudDocumentsMainDirectory: URL? {
        return iCloudDocumentsDirectory
        }
    
    func copyFileToCloud(file: URL) async throws {
        guard let iCloudURL = iCloudDocumentsMainDirectory else {
            throw ArcadiaCloudSyncError.error
        }

        if !FileManager.default.fileExists(atPath: file.path) {
            throw ArcadiaCloudSyncError.error
        }

        let iCloudSubDirectory = iCloudURL
            .appendingPathComponent(file.pathComponents[file.pathComponents.endIndex - 3])
            .appendingPathComponent(file.pathComponents[file.pathComponents.endIndex - 2])

        let iCloudFileURL = iCloudSubDirectory.appendingPathComponent(file.lastPathComponent)

        try FileManager.default.createDirectory(at: iCloudSubDirectory, withIntermediateDirectories: true)

        if FileManager.default.fileExists(atPath: iCloudFileURL.path) {
            let localDate = try FileManager.default.attributesOfItem(atPath: file.path)[.modificationDate] as? Date
            let iCloudDate = try FileManager.default.attributesOfItem(atPath: iCloudFileURL.path)[.modificationDate] as? Date

            if let localDate, let iCloudDate, iCloudDate > localDate {
                return // Skip copy
            } else {
                try FileManager.default.removeItem(at: iCloudFileURL)
            }
        }

        try FileManager.default.copyItem(at: file, to: iCloudFileURL)
    }

    
    func downloadFileFromCloud(localFileURL: URL) async throws {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }
        

            let iCloudFileURL = iCloudURL.appendingPathComponent(localFileURL.pathComponents[localFileURL.pathComponents.index(localFileURL.pathComponents.endIndex, offsetBy: -3)]).appendingPathComponent(localFileURL.pathComponents[localFileURL.pathComponents.index(localFileURL.pathComponents.endIndex, offsetBy: -2)]).appendingPathComponent(localFileURL.lastPathComponent)
            print(iCloudFileURL)
            
            if FileManager.default.fileExists(atPath: iCloudFileURL.path) {

                do {
                    try FileManager.default.removeItem(at: localFileURL)
                    try FileManager.default.copyItem(at: iCloudFileURL, to: localFileURL)
                } catch {
                    print("Could not delete")
                }
            }
        
        
    }
    
    func deleteFileFromCloud(file: URL) async throws {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }
        

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
    
    func renameFileInCloud(file: URL, to newFile: URL) async throws {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }
        

                                    
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
    
    func copyFolderToCloud(folder: URL) async throws {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }
        
        let iCloudSubDirectory = iCloudURL
            .appendingPathComponent(folder.pathComponents[folder.pathComponents.index(folder.pathComponents.endIndex, offsetBy: -2)])
            .appendingPathComponent(folder.lastPathComponent)

        do {
            try FileManager.default.createDirectory(at: iCloudSubDirectory, withIntermediateDirectories: true, attributes: nil)

            let localContents = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.contentModificationDateKey])
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
    
    func downloadFolderFromCloud(folder: URL) async throws {
        
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }
        
        let iCloudSubDirectory = iCloudURL
            .appendingPathComponent(folder.pathComponents[folder.pathComponents.index(folder.pathComponents.endIndex, offsetBy: -2)])
            .appendingPathComponent(folder.lastPathComponent)

        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)

            let localContents = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.contentModificationDateKey])
            let iCloudContents = try FileManager.default.contentsOfDirectory(at: iCloudSubDirectory, includingPropertiesForKeys: [.contentModificationDateKey])

            // Create a dictionary of local files
            var localFilesDict = [String: URL]()
            for localFile in localContents {
                localFilesDict[localFile.lastPathComponent] = localFile
            }

            // Sync iCloud files to local
            for iCloudFile in iCloudContents {
                let localFile = folder.appendingPathComponent(iCloudFile.lastPathComponent)

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
    
    func syncFolderToCloud(folder: URL) async throws {
        guard
            let iCloudURL = iCloudDocumentsMainDirectory
        else { return }
        
        let iCloudSubDirectory = iCloudURL
            .appendingPathComponent(folder.pathComponents[folder.pathComponents.index(folder.pathComponents.endIndex, offsetBy: -2)])
            .appendingPathComponent(folder.lastPathComponent)
        do {
            try FileManager.default.createDirectory(at: iCloudSubDirectory, withIntermediateDirectories: true, attributes: nil)

            let localContents = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.contentModificationDateKey])
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
                    let localFile = folder.appendingPathComponent(iCloudFile.lastPathComponent)
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

    
    func getStatusOfFilesInCloudFolder(localFolderURL: URL) async throws {}
    
    
}
