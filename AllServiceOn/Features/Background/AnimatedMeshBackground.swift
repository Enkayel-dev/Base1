//
//  AnimatedMeshBackground.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

// MARK: - Wave Mask Shape

/// A shape that creates a vertical wave edge for liquid-like transitions.
/// The wave sweeps horizontally based on progress, creating a water-sliding effect.
struct WaveMask: Shape {
    /// Progress of the wave (0 = no reveal, 1 = fully revealed)
    var progress: CGFloat
    
    /// Height of the wave curves
    var amplitude: CGFloat
    
    /// Number of wave cycles along the vertical edge
    var frequency: CGFloat
    
    /// Whether the wave sweeps from right to left (true) or left to right (false)
    var reversed: Bool
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        if reversed {
            // Wave sweeps from right to left
            let waveX = width * (1.0 - progress)
            
            // Start at top-right corner
            path.move(to: CGPoint(x: width, y: 0))
            
            // Draw vertical wave edge (going down)
            for y in stride(from: 0, through: height, by: 1) {
                let relativeY = y / height
                let offset = sin(relativeY * frequency * .pi * 2 + progress * 5) * amplitude
                let x = waveX + offset
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            // Close shape along right edge
            path.addLine(to: CGPoint(x: width, y: height))
            path.closeSubpath()
        } else {
            // Wave sweeps from left to right
            let waveX = width * progress
            
            // Start at top-left corner
            path.move(to: .zero)
            
            // Move to wave start point at top
            path.addLine(to: CGPoint(x: waveX, y: 0))
            
            // Draw vertical wave edge (going down)
            for y in stride(from: 0, through: height, by: 1) {
                let relativeY = y / height
                let offset = sin(relativeY * frequency * .pi * 2 + progress * 5) * amplitude
                let x = waveX + offset
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            // Close shape along left and top edges
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
        }
        
        return path
    }
}

// MARK: - Liquid Background

/// A two-layer gradient background with wave-masked transitions.
/// Replaces MeshGradient with cleaner radial gradients and a custom wave mask
/// for smooth, water-like transitions between color schemes.
public struct AnimatedMeshBackground: View {
    @Environment(BackgroundState.self) private var backgroundState
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Base layer: current scheme gradient
            backgroundState.currentScheme.gradient(for: colorScheme)
                .ignoresSafeArea()
            
            // Incoming layer: next scheme with wave mask (only during transitions)
            if let nextScheme = backgroundState.nextScheme {
                nextScheme.gradient(for: colorScheme)
                    .ignoresSafeArea()
                    .mask(
                        WaveMask(
                            progress: backgroundState.waveProgress,
                            amplitude: backgroundState.waveAmplitude,
                            frequency: backgroundState.waveFrequency,
                            reversed: backgroundState.transitionDirection == .left
                        )
                    )
            }
            
            #if DEBUG
            BackgroundTuningPanel()
            #endif
        }
    }
}

// MARK: - Legacy Initializer

extension AnimatedMeshBackground {
    /// Legacy initializer - scheme is now read from BackgroundState environment
    @available(*, deprecated, message: "Use init() instead. Scheme is now managed by BackgroundState.")
    public init(scheme: MeshScheme) {
        // Scheme parameter is ignored - BackgroundState controls the scheme
    }
}

// MARK: - Previews

#Preview("Gold - Light") {
    let state = BackgroundState()
    state.setScheme(.gold)
    return AnimatedMeshBackground()
        .environment(state)
        .preferredColorScheme(.light)
}

#Preview("Gold - Dark") {
    let state = BackgroundState()
    state.setScheme(.gold)
    return AnimatedMeshBackground()
        .environment(state)
        .preferredColorScheme(.dark)
}

#Preview("Blue - Light") {
    let state = BackgroundState()
    state.setScheme(.blue)
    return AnimatedMeshBackground()
        .environment(state)
        .preferredColorScheme(.light)
}

#Preview("Blue - Dark") {
    let state = BackgroundState()
    state.setScheme(.blue)
    return AnimatedMeshBackground()
        .environment(state)
        .preferredColorScheme(.dark)
}

#Preview("Violet - Light") {
    let state = BackgroundState()
    state.setScheme(.violet)
    return AnimatedMeshBackground()
        .environment(state)
        .preferredColorScheme(.light)
}

#Preview("Violet - Dark") {
    let state = BackgroundState()
    state.setScheme(.violet)
    return AnimatedMeshBackground()
        .environment(state)
        .preferredColorScheme(.dark)
}

// MARK: - Debug Tuning Panel

#if DEBUG
struct BackgroundTuningPanel: View {
    @Environment(BackgroundState.self) private var backgroundState
    @State private var showTuningPanel = false
    
    var body: some View {
        if showTuningPanel {
            @Bindable var state = backgroundState
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Background Tuning")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        showTuningPanel = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                TuningSlider(
                    label: "Duration",
                    value: $state.transitionDuration,
                    range: 0.5...4.0,
                    format: "%.1fs"
                )
                
                TuningSlider(
                    label: "Amplitude",
                    value: Binding(
                        get: { Double(state.waveAmplitude) },
                        set: { state.waveAmplitude = CGFloat($0) }
                    ),
                    range: 0...80,
                    format: "%.0f"
                )
                
                TuningSlider(
                    label: "Frequency",
                    value: Binding(
                        get: { Double(state.waveFrequency) },
                        set: { state.waveFrequency = CGFloat($0) }
                    ),
                    range: 1...8,
                    format: "%.1f"
                )
                
                HStack(spacing: 12) {
                    Button("← Test Left") {
                        backgroundState.transition(to: nextScheme(), direction: .left)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Test Right →") {
                        backgroundState.transition(to: nextScheme(), direction: .right)
                    }
                    .buttonStyle(.bordered)
                }
                .font(.caption)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current: \(backgroundState.currentScheme.rawValue)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    if let next = backgroundState.nextScheme {
                        Text("Next: \(next.rawValue) (\(Int(backgroundState.waveProgress * 100))%)")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding()
            .padding(.top, 60)
        } else {
            // Small toggle button in corner
            Button {
                showTuningPanel = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.top, 60)
            .padding(.leading, 80)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func nextScheme() -> MeshScheme {
        let all = MeshScheme.allCases
        guard let currentIndex = all.firstIndex(of: backgroundState.currentScheme) else {
            return .gold
        }
        let nextIndex = (currentIndex + 1) % all.count
        return all[nextIndex]
    }
}

struct TuningSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Text(String(format: format, value))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.6))
            }
            Slider(value: $value, in: range)
                .tint(.white.opacity(0.8))
        }
    }
}
#endif
