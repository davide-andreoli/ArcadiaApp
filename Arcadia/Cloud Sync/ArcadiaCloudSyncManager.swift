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
    
    func createCloudCopy(of file: URL) async {
        if isEnabled {
            do {
                try await self.driver.copyFileToCloud(file: file)
            }
            catch {
                self.lastSyncStatus = .error
                print("Cloud copy failed: \(error)")
            }
            
        }
    }
    
    func renameFileInCloud(file: URL, to: URL) async {
        if isEnabled {
            do {
                try await self.driver.renameFileInCloud(file: file, to: to)
            }
            catch {
                self.lastSyncStatus = .error
            }
        }
    }
    
    func deleteCloudCopy(of file: URL) async {
        if isEnabled {
            do {
                try await self.driver.deleteFileFromCloud(file: file)
            }
            catch {
                self.lastSyncStatus = .error
            }
        }
    }
    
    func syncFolderToCloud(folder: URL) async {
        if isEnabled {
            do {
                try await self.driver.syncFolderToCloud(folder: folder)
            }
            catch {
                self.lastSyncStatus = .error
            }
        }
    }
    
    func uploadFilesToiCloud() async {
        if isEnabled {
            self.lastSyncStatus = .syncing
            let gameSystems = ArcadiaGameType.allCases

            await withTaskGroup(of: Void.self) { group in
                for gameSystem in gameSystems {
                    let directories = [
                        ArcadiaFileManager.shared.getGameDirectory(for: gameSystem),
                        ArcadiaFileManager.shared.getSaveDirectory(for: gameSystem),
                        ArcadiaFileManager.shared.getStateDirectory(for: gameSystem),
                        ArcadiaFileManager.shared.getImageDirectory(for: gameSystem),
                        ArcadiaFileManager.shared.getCoreDirectory(for: gameSystem)
                    ]
                    for dir in directories {
                        group.addTask {
                            do {
                                try await self.driver.copyFolderToCloud(folder: dir)
                            } catch {
                                print("Error copying \(dir): \(error)")
                                self.lastSyncStatus = .error
                            }
                        }
                    }
                }
            }

            if self.lastSyncStatus != .error {
                self.lastSyncStatus = .completed
            }
        }
    }

    
    func downloadDataFromiCloud() async {
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
                do {
                    try await self.driver.downloadFolderFromCloud(folder: localURL)
                } catch {
                    self.lastSyncStatus = .error
                }
            }
        }
        
    }
    
    func syncDataToiCloud() async {
        if self.isEnabled {
            self.lastSyncStatus = .syncing
            var localURLs = [URL]()
            for gameSystem in ArcadiaGameType.allCases {
                localURLs.append(ArcadiaFileManager.shared.getGameDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getSaveDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getStateDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getImageDirectory(for: gameSystem))
                localURLs.append(ArcadiaFileManager.shared.getCoreDirectory(for: gameSystem))
            }

            for localURL in localURLs {
                do {
                    try await self.driver.syncFolderToCloud(folder: localURL)
                }
                
                catch {
                    self.lastSyncStatus = .error
                }
            }
            
            self.lastSyncStatus = .completed
        }
        
    }

    
}
