//
//  BusinessProfile.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

struct BusinessProfile: View {
    @Environment(TabRouter.self) private var tabRouter
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Centered title matching other views
            Text("Business Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 0)
            
            // Mock Content
            List {
                Section("Information") {
                    Text("Business Name")
                    Text("Contact Details")
                }
                
                Section("Team") {
                    Text("Manage Members")
                    Text("Roles & Permissions")
                }
                
                Section("Integrations") {
                    Text("Connected Apps")
                    Text("API Keys")
                }
            }
            .scrollContentBackground(.hidden) // Allow mesh background to show through
            
            Spacer()
        }
        .padding(.top, 0)
    }
}

#Preview {
    ZStack {
        Color.teal.ignoresSafeArea()
        BusinessProfile()
            .environment(TabRouter())
    }
}
