//
//  AnimatedMeshBackground.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//
import SwiftUI

public struct AnimatedMeshBackground: View {
    public let scheme: MeshScheme
    
    public init(scheme: MeshScheme) {
        self.scheme = scheme
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        TimelineView(.animation) { context in
            let s = context.date.timeIntervalSince1970
            let v = Float(sin(s)) / 16
            
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    SIMD2<Float>(0.0, 0.0), SIMD2<Float>(0.5, 0.0), SIMD2<Float>(1.0, 0.0),
                    SIMD2<Float>(0.0, 0.5), SIMD2<Float>(0.5 + v, 0.5 - v), SIMD2<Float>(1.0, 0.5 - v),
                    SIMD2<Float>(0.0, 1.0), SIMD2<Float>(0.5 - v, 1.0), SIMD2<Float>(1.0, 1.0),
                ],
                colors: colors(for: scheme, in: colorScheme)
            )
        }
        .ignoresSafeArea()
    }
    
    private func colors(for scheme: MeshScheme, in colorScheme: ColorScheme) -> [Color] {
        let isLight = colorScheme == .light
        
        switch scheme {
            
        case .gold: // #E0BC16
            if isLight {
                return [
                    Color(red: 1.0, green: 0.98, blue: 0.85),
                    Color(red: 0.95, green: 0.85, blue: 0.40),
                    Color(red: 0.90, green: 0.80, blue: 0.20),
                    
                    Color(red: 1.0, green: 0.98, blue: 0.90),
                    Color(red: 0.98, green: 0.90, blue: 0.50),
                    Color(red: 0.92, green: 0.82, blue: 0.30),
                    
                    Color(red: 1.0, green: 0.95, blue: 0.88),
                    Color(red: 0.95, green: 0.88, blue: 0.45),
                    Color(red: 0.85, green: 0.75, blue: 0.25),
                ]
            } else {
                return [
                    Color(red: 0.95, green: 0.88, blue: 0.50),
                    Color(red: 0.88, green: 0.74, blue: 0.09),
                    Color(red: 0.72, green: 0.60, blue: 0.05),
                    
                    Color(red: 1.00, green: 0.93, blue: 0.65),
                    Color(red: 0.90, green: 0.78, blue: 0.25),
                    Color(red: 0.75, green: 0.62, blue: 0.15),
                    
                    Color(red: 0.98, green: 0.90, blue: 0.75),
                    Color(red: 0.85, green: 0.70, blue: 0.20),
                    Color(red: 0.60, green: 0.50, blue: 0.10),
                ]
            }
            
        case .amber: // #E07416
            if isLight {
                return [
                    Color(red: 1.0, green: 0.90, blue: 0.80),
                    Color(red: 1.0, green: 0.75, blue: 0.50),
                    Color(red: 0.95, green: 0.60, blue: 0.30),
                    
                    Color(red: 1.0, green: 0.95, blue: 0.85),
                    Color(red: 1.0, green: 0.80, blue: 0.60),
                    Color(red: 0.98, green: 0.65, blue: 0.40),
                    
                    Color(red: 1.0, green: 0.92, blue: 0.85),
                    Color(red: 1.0, green: 0.70, blue: 0.45),
                    Color(red: 0.90, green: 0.55, blue: 0.35),
                ]
            } else {
                return [
                    Color(red: 0.95, green: 0.65, blue: 0.35),
                    Color(red: 0.88, green: 0.45, blue: 0.09),
                    Color(red: 0.70, green: 0.32, blue: 0.05),
                    
                    Color(red: 1.00, green: 0.78, blue: 0.55),
                    Color(red: 0.90, green: 0.55, blue: 0.20),
                    Color(red: 0.75, green: 0.40, blue: 0.15),
                    
                    Color(red: 0.98, green: 0.85, blue: 0.70),
                    Color(red: 0.85, green: 0.50, blue: 0.25),
                    Color(red: 0.60, green: 0.30, blue: 0.15),
                ]
            }
            
        case .blue: // #1F76E8
            if isLight {
                return [
                    Color(red: 0.85, green: 0.92, blue: 1.0),
                    Color(red: 0.60, green: 0.80, blue: 1.0),
                    Color(red: 0.40, green: 0.60, blue: 0.90),
                    
                    Color(red: 0.90, green: 0.95, blue: 1.0),
                    Color(red: 0.70, green: 0.85, blue: 1.0),
                    Color(red: 0.50, green: 0.70, blue: 0.95),
                    
                    Color(red: 0.92, green: 0.96, blue: 1.0),
                    Color(red: 0.75, green: 0.88, blue: 1.0),
                    Color(red: 0.55, green: 0.75, blue: 0.92),
                ]
            } else {
                return [
                    Color(red: 0.15, green: 0.30, blue: 0.55),
                    Color(red: 0.12, green: 0.46, blue: 0.91),
                    Color(red: 0.08, green: 0.25, blue: 0.55),
                    
                    Color(red: 0.45, green: 0.65, blue: 0.95),
                    Color(red: 0.25, green: 0.50, blue: 0.85),
                    Color(red: 0.15, green: 0.35, blue: 0.70),
                    
                    Color(red: 0.65, green: 0.78, blue: 0.98),
                    Color(red: 0.30, green: 0.55, blue: 0.90),
                    Color(red: 0.10, green: 0.25, blue: 0.55),
                ]
            }
            
        case .crimson: // #990E0D
            if isLight {
                return [
                    Color(red: 1.0, green: 0.90, blue: 0.90),
                    Color(red: 1.0, green: 0.70, blue: 0.70),
                    Color(red: 0.90, green: 0.50, blue: 0.50),
                    
                    Color(red: 1.0, green: 0.95, blue: 0.95),
                    Color(red: 1.0, green: 0.80, blue: 0.80),
                    Color(red: 0.95, green: 0.60, blue: 0.60),
                    
                    Color(red: 1.0, green: 0.92, blue: 0.92),
                    Color(red: 1.0, green: 0.75, blue: 0.75),
                    Color(red: 0.92, green: 0.55, blue: 0.55),
                ]
            } else {
                return [
                    Color(red: 0.60, green: 0.06, blue: 0.05),
                    Color(red: 0.85, green: 0.20, blue: 0.18),
                    Color(red: 0.45, green: 0.05, blue: 0.05),
                    
                    Color(red: 0.95, green: 0.45, blue: 0.40),
                    Color(red: 0.75, green: 0.15, blue: 0.12),
                    Color(red: 0.55, green: 0.10, blue: 0.10),
                    
                    Color(red: 0.98, green: 0.65, blue: 0.60),
                    Color(red: 0.65, green: 0.20, blue: 0.18),
                    Color(red: 0.35, green: 0.05, blue: 0.05),
                ]
            }
            
        case .mint: // #0BBA77
            if isLight {
                return [
                    Color(red: 0.90, green: 1.0, blue: 0.95),
                    Color(red: 0.70, green: 0.95, blue: 0.85),
                    Color(red: 0.50, green: 0.85, blue: 0.70),
                    
                    Color(red: 0.95, green: 1.0, blue: 0.98),
                    Color(red: 0.80, green: 0.98, blue: 0.90),
                    Color(red: 0.60, green: 0.90, blue: 0.80),
                    
                    Color(red: 0.92, green: 1.0, blue: 0.96),
                    Color(red: 0.75, green: 0.96, blue: 0.88),
                    Color(red: 0.55, green: 0.88, blue: 0.75),
                ]
            } else {
                return [
                    Color(red: 0.05, green: 0.35, blue: 0.25),
                    Color(red: 0.04, green: 0.73, blue: 0.47),
                    Color(red: 0.05, green: 0.50, blue: 0.35),
                    
                    Color(red: 0.40, green: 0.90, blue: 0.70),
                    Color(red: 0.20, green: 0.80, blue: 0.60),
                    Color(red: 0.10, green: 0.60, blue: 0.45),
                    
                    Color(red: 0.70, green: 0.95, blue: 0.85),
                    Color(red: 0.25, green: 0.75, blue: 0.55),
                    Color(red: 0.05, green: 0.40, blue: 0.30),
                ]
            }
            
        case .violet: // #A66EA4
            if isLight {
                return [
                    Color(red: 0.95, green: 0.90, blue: 0.95),
                    Color(red: 0.90, green: 0.80, blue: 0.90),
                    Color(red: 0.80, green: 0.65, blue: 0.80),
                    
                    Color(red: 0.98, green: 0.95, blue: 0.98),
                    Color(red: 0.95, green: 0.85, blue: 0.95),
                    Color(red: 0.85, green: 0.75, blue: 0.85),
                    
                    Color(red: 0.96, green: 0.92, blue: 0.96),
                    Color(red: 0.92, green: 0.82, blue: 0.92),
                    Color(red: 0.82, green: 0.70, blue: 0.85),
                ]
            } else {
                return [
                    Color(red: 0.40, green: 0.25, blue: 0.40),
                    Color(red: 0.65, green: 0.43, blue: 0.64),
                    Color(red: 0.30, green: 0.15, blue: 0.30),
                    
                    Color(red: 0.85, green: 0.70, blue: 0.85),
                    Color(red: 0.70, green: 0.50, blue: 0.70),
                    Color(red: 0.50, green: 0.30, blue: 0.50),
                    
                    Color(red: 0.95, green: 0.85, blue: 0.95),
                    Color(red: 0.60, green: 0.45, blue: 0.65),
                    Color(red: 0.35, green: 0.20, blue: 0.40),
                ]
            }
        }
    }
}


#Preview {
    AnimatedMeshBackground(scheme: .violet)
}
