//
//  BackgroundState.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import Observation

/// Transition direction for wave animation bias
public enum TransitionDirection {
    case left   // Navigating to lower tab index (wave sweeps right to left)
    case right  // Navigating to higher tab index (wave sweeps left to right)
    case none   // No transition or same tab
}

@MainActor @Observable
public final class BackgroundState {
    
    // MARK: - Current State
    
    /// The current (base) scheme being displayed
    public private(set) var currentScheme: MeshScheme = .gold
    
    /// The incoming scheme during a transition (nil when not transitioning)
    public private(set) var nextScheme: MeshScheme?
    
    /// Progress of the wave mask (0 = no reveal, 1 = fully revealed)
    public private(set) var waveProgress: Double = 0.0
    
    /// Direction of the transition for wave sweep
    public private(set) var transitionDirection: TransitionDirection = .none
    
    /// Whether a transition is currently active
    public var isTransitioning: Bool {
        nextScheme != nil && waveProgress < 1.0
    }
    
    // MARK: - Tunable Parameters
    
    /// Wave amplitude (height of the wave curves)
    public var waveAmplitude: CGFloat = 30
    
    /// Wave frequency (number of wave cycles)
    public var waveFrequency: CGFloat = 3
    
    /// Transition duration in seconds
    public var transitionDuration: Double = 1.8
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Transition API
    
    /// Transition to a new scheme with wave animation
    /// - Parameters:
    ///   - newScheme: The target color scheme
    ///   - direction: The direction of navigation (affects wave sweep direction)
    public func transition(
        to newScheme: MeshScheme,
        direction: TransitionDirection = .none
    ) {
        // Skip if already at this scheme and not transitioning
        guard newScheme != currentScheme || isTransitioning else { return }
        
        // Set up the transition
        nextScheme = newScheme
        transitionDirection = direction
        waveProgress = 0.0
        
        // Animate wave progress to 1.0
        withAnimation(.easeInOut(duration: transitionDuration)) {
            waveProgress = 1.0
        }
        
        // Complete the transition after animation
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(transitionDuration))
            completeTransition()
        }
    }
    
    /// Complete the transition, making the next scheme current
    private func completeTransition() {
        guard let next = nextScheme else { return }
        currentScheme = next
        nextScheme = nil
        waveProgress = 0.0
        transitionDirection = .none
    }
    
    /// Instantly set scheme without animation (for initial setup)
    public func setScheme(_ scheme: MeshScheme) {
        currentScheme = scheme
        nextScheme = nil
        waveProgress = 0.0
        transitionDirection = .none
    }
}

