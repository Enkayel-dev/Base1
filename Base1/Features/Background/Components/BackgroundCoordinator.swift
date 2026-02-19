//
//  BackgroundCoordinator.swift
//  Base1
//

import SwiftUI
import Observation

@MainActor @Observable
final class BackgroundCoordinator {
    
    private let service: BackgroundService
    private let state: BackgroundState
    
    init(service: BackgroundService, state: BackgroundState) {
        self.service = service
        self.state = state
    }
    
    func tabDidChange(to index: Int) {
        let newScheme = service.preferredScheme(for: index)
        
        guard newScheme != state.scheme else { return }
        
        withAnimation(.easeInOut(duration: 0.6)) {
            state.scheme = newScheme
        }
    }
}

