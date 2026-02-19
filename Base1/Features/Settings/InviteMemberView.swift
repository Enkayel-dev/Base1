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
    @Environment(\.dismissDrawer) private var dismiss

    @State private var email = ""
    @State private var displayName = ""
    @State private var role: MemberRole = .member
    @State private var hourlyRate = ""

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Invite Member",
                leadingAction: { dismiss() },
                trailingText: "Send Invite",
                trailingAction: { saveMember() },
                isTrailingDisabled: email.isEmpty || displayName.isEmpty
            )

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

                            Divider()

                            LabeledTextField("Hourly Rate", text: $hourlyRate, icon: "dollarsign", keyboardType: .decimalPad)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.clear)
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }

    private func saveMember() {
        guard let businessKey = businessManager.businessKey else { return }

        let member = Member(
            businessKey: businessKey,
            email: email,
            displayName: displayName,
            role: role,
            inviteStatus: .pending,
            hourlyRate: Decimal(string: hourlyRate)
        )
        member.business = businessManager.currentBusiness

        modelContext.insert(member)
        dismiss()
    }
}
