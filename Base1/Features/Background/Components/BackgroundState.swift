//
//  BackgroundState.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//
//
//  BackgroundState.swift
//  Base1
//

import SwiftUI
import Observation

@MainActor @Observable
public final class BackgroundState {
    public var scheme: MeshScheme = .blue
    public var transitionProgress: Double = 1.0
    
    public init() {}
}

