//
//  Tab3View.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct Tab3View: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Tab 3")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Third tab content")
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
            .scrollContentBackground(.hidden) // Hide any scroll view backgrounds
            .navigationTitle("Tab 3")
            .navigationBarTitleDisplayMode(.inline) // Prevent large title background
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .background(.clear) // CRITICAL: Ensure NavigationStack itself is transparent
    }
}

#Preview {
    ZStack {
        AnimatedMeshBackground()
        Tab3View()
    }
}

