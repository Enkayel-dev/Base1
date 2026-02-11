//
//  InviteMemberView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct InviteMemberView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var displayName = ""
    @State private var role: MemberRole = .member

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 24) {
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
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Invite Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send Invite") { saveMember() }
                        .disabled(email.isEmpty || displayName.isEmpty)
                }
            }
        }
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func saveMember() {
        guard let businessKey = businessManager.businessKey else { return }

        let member = Member(
            businessKey: businessKey,
            email: email,
            displayName: displayName,
            role: role,
            inviteStatus: .pending
        )
        member.business = businessManager.currentBusiness

        modelContext.insert(member)
        dismiss()
    }
}
