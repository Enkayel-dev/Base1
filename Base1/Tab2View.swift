//
//  Tab2View.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct Tab2View: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()
                
                VStack {
                    Text("Tab 2")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text("Second tab content")
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .navigationTitle("Tab 2")
        }
    }
}

#Preview {
    Tab2View()
}
