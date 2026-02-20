//
//  SettingsView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(TabRouter.self) private var tabRouter
    @Environment(AuthService.self) private var authService
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(BusinessManager.self) private var businessManager
    @Environment(DrawerRouter.self) private var drawerRouter
    
    @Query private var members: [Member]
    
    @State private var showingSubscription = false
    @State private var showingSignOutConfirm = false
    
    /// Filter members for current business
    private var businessMembers: [Member] {
        guard let key = businessManager.businessKey else { return [] }
        return members.filter { $0.businessKey == key }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Centered title matching Tab1View style
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 0)
            
            List {
                Section("General") {
                    Text("Appearance")
                    Text("Notifications")
                }
                
                Section("Account") {
                    // Current user info
                    if let credentials = authService.credentials {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading) {
                                Text(credentials.displayName)
                                    .font(.headline)
                                if let email = credentials.email {
                                    Text(email)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Subscription
                    Button {
                        showingSubscription = true
                    } label: {
                        HStack {
                            Text("Subscription")
                            Spacer()
                            Text(subscriptionManager.currentTier.displayName)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    // Sign Out
                    Button(role: .destructive) {
                        showingSignOutConfirm = true
                    } label: {
                        Text("Sign Out")
                    }
                }
                
                // Debug section (only in DEBUG builds)
                #if DEBUG
                debugSection
                #endif
                
                Section("About") {
                    Text("Version 1.0.0")
                    Text("Privacy Policy")
                }
            }
            .scrollContentBackground(.hidden)
            
            Spacer()
        }
        .padding(.top, 0)
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
        .confirmationDialog(
            "Sign Out",
            isPresented: $showingSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                authService.signOut()
                businessManager.signOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    // MARK: - Debug Section
    
    #if DEBUG
    @ViewBuilder
    private var debugSection: some View {
        Section("Debug: Role Testing") {
            @Bindable var manager = businessManager
            
            Toggle("Enable Debug Mode", isOn: $manager.debugModeEnabled)
            
            if businessManager.debugModeEnabled {
                // Current role display
                HStack {
                    Text("Current Role")
                    Spacer()
                    Text(businessManager.currentUserRole.displayTitle)
                        .foregroundStyle(.secondary)
                }
                
                // Member picker
                Picker("Test as Member", selection: $manager.debugSelectedMember) {
                    Text("Owner (default)")
                        .tag(Member?.none)
                    
                    ForEach(businessMembers) { member in
                        Text("\(member.displayName) (\(member.role.displayTitle))")
                            .tag(Member?.some(member))
                    }
                }
                
                // Quick role buttons
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Switch:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(MemberRole.allCases, id: \.self) { role in
                            Button {
                                selectMemberWithRole(role)
                            } label: {
                                Text(role.displayTitle)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        businessManager.currentUserRole == role
                                            ? Color.accentColor
                                            : Color(.tertiarySystemFill)
                                    )
                                    .foregroundStyle(
                                        businessManager.currentUserRole == role
                                            ? .white
                                            : .primary
                                    )
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Info text
                Text("Debug mode lets you test role-based views without multiple iCloud accounts.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func selectMemberWithRole(_ role: MemberRole) {
        if role == .owner {
            businessManager.debugSelectedMember = nil
        } else if let member = businessMembers.first(where: { $0.role == role }) {
            businessManager.debugSelectedMember = member
        } else {
            // No member with this role exists - show message or create test member
            businessManager.debugSelectedMember = nil
        }
    }
    #endif
}

#Preview {
    ZStack {
        Color.purple.ignoresSafeArea()
        SettingsView()
            .environment(TabRouter())
            .environment(AuthService())
            .environment(SubscriptionManager())
            .environment(BusinessManager(container: try! ModelContainer(for: Business.self)))
            .environment(DrawerRouter())
    }
}
