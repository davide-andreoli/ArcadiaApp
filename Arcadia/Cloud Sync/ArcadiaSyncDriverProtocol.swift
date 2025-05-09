//
//  ArcadiaSyncDriverProtocol.swift
//  Arcadia
//
//  Created by Davide Andreoli on 07/05/25.
//
import Foundation

protocol ArcadiaSyncDriverProtocol {
    
    func copyFileToCloud(file: URL) async throws
    
    func downloadFileFromCloud(localFileURL: URL) async throws
    
    func deleteFileFromCloud(file: URL) async throws
    
    func renameFileInCloud(file: URL, to newFile: URL) async throws
    
    func copyFolderToCloud(folder: URL) async throws
    
    func downloadFolderFromCloud(folder: URL) async throws
    
    func syncFolderToCloud(folder: URL) async throws
    
    func getStatusOfFilesInCloudFolder(localFolderURL: URL) async throws
    
}

