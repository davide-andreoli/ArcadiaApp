//
//  ArcadiaCloudSyncManager.swift
//  Arcadia
//
//  Created by Davide Andreoli on 09/05/25.
//

import Foundation

@Observable class ArcadiaCloudSyncManager {
    public static var shared = ArcadiaCloudSyncManager()
    private var driver: ArcadiaSyncDriverProtocol
    public var lastSyncStatus: ArcadiaCloudSyncStatus = .notExecuted
    
    private init() {
        
        self.driver = ArcadiaiCloudSyncDriver()
    }
    
    public var isEnabled: Bool {
        if let cloudSyncEnabled = UserDefaults.standard.object(forKey: "iCloudSyncEnabled") as? Bool {
            return cloudSyncEnabled
        } else {
            return false
        }
    }
    
    private func generateLocalManifest() {}
    
    private func fetchRemoteManifest() {}
    
    func createCloudCopy(of file: URL) {
        if isEnabled {
            self.driver.copyFileToCloud(file: file)
        }
    }
    
    func renameFileInCloud(file: URL, to: URL) {
        if isEnabled {
            self.driver.renameFileInCloud(file: file, to: to)
        }
    }
    
    func deleteCloudCopy(of file: URL) {
        if isEnabled {
            self.driver.deleteFileFromCloud(file: file)
        }
    }
    
    func syncFolderToCloud(folder: URL) {
        if isEnabled {
            self.driver.syncFolderToCloud(folder: folder)
        }
    }
    
    func uploadFilesToiCloud() {
        if isEnabled {
            var localURLs = [URL]()
            for gameSystem in ArcadiaGameType.allCases {
                localURLs.append(ArcadiaFileManager.shared.getGameDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getSaveDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getStateDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getImageDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getCoreDirectory(for: gameSystem))
            }
            
            for localURL in localURLs {
                self.driver.copyFolderToCloud(folder: localURL)
            }
        }
        
    }
    
    func downloadDataFromiCloud() {
        if isEnabled {
            var localURLs = [URL]()
            for gameSystem in ArcadiaGameType.allCases {
                localURLs.append(ArcadiaFileManager.shared.getGameDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getSaveDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getStateDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getImageDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getCoreDirectory(for: gameSystem))
            }
            
            for localURL in localURLs {
                self.driver.downloadFolderFromCloud(folder: localURL)
            }
        }
        
    }
    
    func syncDataToiCloud() {
        if isEnabled {
            lastSyncStatus = .syncing
            var localURLs = [URL]()
            for gameSystem in ArcadiaGameType.allCases {
                localURLs.append(ArcadiaFileManager.shared.getGameDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getSaveDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getStateDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getImageDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getCoreDirectory(for: gameSystem))
            }

            for localURL in localURLs {
                self.driver.syncFolderToCloud(folder: localURL)
            }
            
            lastSyncStatus = .completed
        }
        
    }

    
}
