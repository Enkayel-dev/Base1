//
//  InviteMemberView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData
import CloudKit

struct InviteMemberView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(CloudKitSharingService.self) private var sharingService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    @Query private var existingMembers: [Member]
    
    @State private var email = ""
    @State private var displayName = ""
    @State private var role: MemberRole = .member
    @State private var hourlyRate = ""
    @State private var isCreatingShare = false
    @State private var shareURL: URL?
    @State private var showingShareSheet = false
    @State private var errorMessage: String?
    
    /// Filter members for current business
    private var businessMemberCount: Int {
        guard let key = businessManager.businessKey else { return 0 }
        return existingMembers.filter { $0.businessKey == key }.count
    }
    
    /// Check if team limit is reached based on subscription
    private var isTeamLimitReached: Bool {
        !subscriptionManager.canAddTeamMember(currentCount: businessMemberCount)
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Invite Member",
                leadingAction: { dismiss() },
                trailingText: "Send Invite",
                trailingAction: { sendInvite() },
                isTrailingDisabled: email.isEmpty || displayName.isEmpty || isCreatingShare || isTeamLimitReached
            )

            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Team limit warning
                        if isTeamLimitReached {
                            teamLimitWarning
                        }
                        
                        sectionCard {
                            LabeledTextField("Email", text: $email, icon: "envelope", keyboardType: .emailAddress)

                            Divider()

                            LabeledTextField("Display Name", text: $displayName, icon: "person")

                            Divider()

                            VStack(alignment: .leading, spacing: 8) {
                                Label("Role", systemImage: "shield")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Picker("Role", selection: $role) {
                                    Text("Admin").tag(MemberRole.admin)
                                    Text("Member").tag(MemberRole.member)
                                }
                                .pickerStyle(.segmented)
                            }

                            Divider()

                            LabeledTextField("Hourly Rate", text: $hourlyRate, icon: "dollarsign", keyboardType: .decimalPad)
                        }
                        
                        // Error message
                        if let error = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                Text(error)
                                    .font(.caption)
                            }
                            .padding()
                            .background(.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Share link section (shown after invite is created)
                        if let url = shareURL {
                            shareLinkSection(url: url)
                        }
                        
                        // Info text
                        infoText
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.clear)
        .overlay {
            if isCreatingShare {
                ProgressView("Creating invite...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    // MARK: - Team Limit Warning
    
    private var teamLimitWarning: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Team Limit Reached")
                    .font(.headline)
            }
            
            Text("Your \(subscriptionManager.currentTier.displayName) plan allows up to \(subscriptionManager.currentTier.maxTeamMembers) team members.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Upgrade to add more members.")
                .font(.caption)
                .foregroundStyle(Color.accentColor)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Share Link Section
    
    private func shareLinkSection(url: URL) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Invite Created")
                    .font(.headline)
            }
            
            Text("Share this link with \(displayName) to invite them to your team.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button {
                    UIPasteboard.general.url = url
                } label: {
                    Label("Copy Link", systemImage: "doc.on.doc")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.thinMaterial)
                        .cornerRadius(8)
                }
                
                Button {
                    showingShareSheet = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Info Text
    
    private var infoText: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("How invites work", systemImage: "info.circle")
                .font(.caption)
                .fontWeight(.medium)
            
            Text("When you send an invite, the team member will receive a link to join your business. They'll need to sign in with their Apple ID to accept.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }

    // MARK: - Send Invite
    
    private func sendInvite() {
        guard let businessKey = businessManager.businessKey,
              let business = businessManager.currentBusiness else { return }
        
        isCreatingShare = true
        errorMessage = nil
        
        // Create member record
        let member = Member(
            businessKey: businessKey,
            email: email,
            displayName: displayName,
            role: role,
            inviteStatus: .pending,
            hourlyRate: Decimal(string: hourlyRate)
        )
        member.business = business
        modelContext.insert(member)
        
        // Create CloudKit share for the invite
        Task {
            do {
                let share = try await sharingService.createBusinessShare(
                    for: business,
                    invitingMember: member
                )
                
                await MainActor.run {
                    shareURL = share.url
                    isCreatingShare = false
                    
                    // Save the context
                    try? modelContext.save()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isCreatingShare = false
                    
                    // Still save the member even if share creation fails
                    // They can be re-invited later
                    try? modelContext.save()
                }
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
