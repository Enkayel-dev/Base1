//
//  Tab1View.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct Tab1View: View {
    var body: some View {
        
            VStack {
                Text("Tab 1")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("First tab content")
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }


#Preview {
    ZStack {
        
        Tab1View()
        
    }
}

