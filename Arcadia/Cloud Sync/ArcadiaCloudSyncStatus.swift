//
//  ArcadiaCloudSyncStatus.swift
//  Arcadia
//
//  Created by Davide Andreoli on 09/05/25.
//

import Foundation

enum ArcadiaCloudSyncStatus {
    case syncing
    case completed
    case error
    case notExecuted
    
    var textToShow: String {
        switch self {
        case .syncing:
            return "Sync in progress"
        case .completed:
            return "Sync completed"
        case .notExecuted:
            return "Sync not yet executed"
        case .error:
            return "Error during last sync"
        }
    }
}
