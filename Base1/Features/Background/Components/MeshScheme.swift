//
//  MeshScheme.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

public enum MeshScheme: String, CaseIterable, Hashable {
    case gold
    case amber
    case blue
    case crimson
    case mint
    case violet
    case teal
    
    // MARK: - Radial Gradient Background
    
    /// Returns a radial gradient view for this color scheme.
    /// Uses Apple system colors that automatically adapt to light/dark mode.
    @ViewBuilder
    func gradient(for colorScheme: ColorScheme) -> some View {
        let isDark = colorScheme == .dark
        
        switch self {
        case .gold:
            RadialGradient(
                colors: isDark
                    ? [Color.orange, Color.yellow.mix(with: .orange, by: 0.5), Color.black]
                    : [Color.yellow, Color.orange, Color.white],
                center: .center,
                startRadius: 10,
                endRadius: 600
            )
            
        case .amber:
            RadialGradient(
                colors: isDark
                    ? [Color.orange.mix(with: .red, by: 0.3), Color.orange, Color.black]
                    : [Color.orange, Color.yellow, Color.white],
                center: .center,
                startRadius: 10,
                endRadius: 600
            )
            
        case .blue:
            RadialGradient(
                colors: isDark
                    ? [Color.indigo, Color.blue, Color.black]
                    : [Color.cyan, Color.blue, Color.white],
                center: .center,
                startRadius: 10,
                endRadius: 600
            )
            
        case .crimson:
            RadialGradient(
                colors: isDark
                    ? [Color.red, Color.red.mix(with: .pink, by: 0.3), Color.black]
                    : [Color.red.mix(with: .pink, by: 0.3), Color.red, Color.white],
                center: .center,
                startRadius: 10,
                endRadius: 600
            )
            
        case .mint:
            RadialGradient(
                colors: isDark
                    ? [Color.mint, Color.green.mix(with: .teal, by: 0.3), Color.black]
                    : [Color.mint, Color.green.mix(with: .mint, by: 0.5), Color.white],
                center: .center,
                startRadius: 10,
                endRadius: 600
            )
            
        case .violet:
            RadialGradient(
                colors: isDark
                    ? [Color.purple, Color.indigo, Color.black]
                    : [Color.purple.mix(with: .pink, by: 0.3), Color.purple, Color.white],
                center: .center,
                startRadius: 10,
                endRadius: 600
            )
            
        case .teal:
            RadialGradient(
                colors: isDark
                    ? [Color.teal, Color.cyan.mix(with: .blue, by: 0.3), Color.black]
                    : [Color.cyan, Color.teal, Color.white],
                center: .center,
                startRadius: 10,
                endRadius: 600
            )
        }
    }
}
