//
//  AnimatedMeshBackground.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct AnimatedMeshBackground: View {
    var body: some View {
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
                colors: [
                    Color(red: 0.115, green: 0.250, blue: 0.121), // seafoam
                    Color(red: 0.115, green: 0.252, blue: 0.214), // ocean blue
                    Color(red: 0.18, green: 0.42, blue: 0.65), // deep water
                    
                    Color(red: 0.65, green: 0.90, blue: 0.85), // shallow lagoon
                    Color(red: 0.35, green: 0.72, blue: 0.75), // tidal
                    Color(red: 0.20, green: 0.50, blue: 0.70), // atlantic
                    
                    Color(red: 0.75, green: 0.92, blue: 0.88), // sea glass
                    Color(red: 0.45, green: 0.78, blue: 0.80), // aqua
                    Color(red: 0.15, green: 0.35, blue: 0.55), // abyss
                ])
        }.ignoresSafeArea()
    }
}

#Preview {
    AnimatedMeshBackground()
}
