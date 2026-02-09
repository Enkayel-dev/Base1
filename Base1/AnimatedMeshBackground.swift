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
            let v = Float(sin(s)) / 4
            
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    SIMD2<Float>(0.0, 0.0), SIMD2<Float>(0.5, 0.0), SIMD2<Float>(1.0, 0.0),
                    SIMD2<Float>(0.0, 0.5), SIMD2<Float>(0.5 + v, 0.5 - v), SIMD2<Float>(1.0, 0.5 - v),
                    SIMD2<Float>(0.0, 1.0), SIMD2<Float>(0.5 - v, 1.0), SIMD2<Float>(1.0, 1.0),
                ],
                colors: [
                    .red, .purple, .blue,
                    .orange, .yellow, .cyan,
                    .pink, .indigo, .blue,
                ])
        }
    }
}

#Preview {
    AnimatedMeshBackground()
}
