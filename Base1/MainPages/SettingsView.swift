//
//  SettingsView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

struct SettingsView: View {
    @Environment(TabRouter.self) private var tabRouter
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Centered title matching Tab1View style
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 0)
            
            // Mock Content
            List {
                Section("General") {
                    Text("Appearance")
                    Text("Notifications")
                }
                
                Section("Account") {
                    Text("Profile")
                    Text("Subscription")
                }
                
                Section("About") {
                    Text("Version 1.0.0")
                    Text("Privacy Policy")
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
        Color.purple.ignoresSafeArea()
        SettingsView()
            .environment(TabRouter())
    }
}
