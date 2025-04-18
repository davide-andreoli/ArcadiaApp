//
//  ArcadiaNavigationState.swift
//  Arcadia
//
//  Created by Davide Andreoli on 13/09/24.
//

import Foundation

@Observable class ArcadiaNavigationState {
    public static var shared = ArcadiaNavigationState()
    public var currentGameSystem: ArcadiaGameType?
    public var importedURL: URL?
    
    private init() {
        self.currentGameSystem = nil
    }
    
    
    
}
