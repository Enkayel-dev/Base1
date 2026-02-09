//
//  Tab3View.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct Tab3View: View {
    var body: some View {
        
            VStack {
                Text("Tab 3")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Third tab content")
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }


#Preview {
    ZStack {
        AnimatedMeshBackground()
        Tab3View()
        
    }
}

