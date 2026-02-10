//
//  Tab1View.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct Tab1View: View {
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                
                Text("Clients")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
            }
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

