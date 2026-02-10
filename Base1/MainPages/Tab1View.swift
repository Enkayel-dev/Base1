//
//  Tab1View.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct Tab1View: View {
    @State private var selectedFilter: FilterOption = .all
    
    var body: some View {
        VStack(spacing: 20) {
            // Centered title at the top
            Text("Clients")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 0)
            
            // Filter picker
            LiquidGlassFilterPicker(selectedFilter: $selectedFilter)
                .padding(.horizontal)
            
            Spacer()
        }
    }
}


#Preview {
    ZStack {
        AnimatedMeshBackground()
        Tab1View()
        
    }
}

