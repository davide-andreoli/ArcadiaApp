//
//  ArcadiaSyncDriverProtocol.swift
//  Arcadia
//
//  Created by Davide Andreoli on 07/05/25.
//
import Foundation

protocol ArcadiaSyncDriverProtocol {
    
    func copyFileToCloud(file: URL)
    
    func downloadFileFromCloud(localFileURL: URL)
    
    func deleteFileFromCloud(file: URL)
    
    func renameFileInCloud(file: URL, to newFile: URL)
    
    func copyFolderToCloud(folder: URL)
    
    func downloadFolderFromCloud(folder: URL)
    
    func syncFolderToCloud(folder: URL)
    
    func getStatusOfFilesInCloudFolder(localFolderURL: URL)
    
}

