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
    
    /// Transition background for tab change with direction detection
    func tabDidChange(from oldIndex: Int, to newIndex: Int) {
        let newScheme = service.preferredScheme(for: newIndex)
        let direction: TransitionDirection = newIndex > oldIndex ? .right : .left
        
        state.transition(to: newScheme, direction: direction)
    }
}

