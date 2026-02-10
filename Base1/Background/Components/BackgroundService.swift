//
//  BackgroundService.swift
//  Base1
//

import Foundation

public final class BackgroundService {
    
    public init() {}
    
    public func preferredScheme(for tab: Int) -> MeshScheme {
        switch tab {
        case 0: return .gold
        case 1: return .amber
        case 2: return .blue
        case 3: return .crimson
        case 4: return .mint
        default: return .violet
        }
    }
}

