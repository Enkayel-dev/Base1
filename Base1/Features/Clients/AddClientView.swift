//
//  AddClientView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData
import UIKit

struct AddClientView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSource: ClientSource = .manual

    // MARK: - Manual Form Fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var hasCompany = false
    @State private var companyName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // MARK: - Source Picker
                sourcePicker

                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedSource {
                        case .manual:
                            manualFormContent
                        case .googleAds:
                            googleAdsPlaceholder
                        case .squarespace:
                            squarespacePlaceholder
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Add Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if selectedSource == .manual {
                        Button("Save") { saveClient() }
                            .disabled(firstName.isEmpty || lastName.isEmpty)
                    }
                }
            }
        }
    }

    // MARK: - Source Picker

    private var sourcePicker: some View {
        HStack(spacing: 8) {
            ForEach(ClientSource.allCases) { source in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedSource = source
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: source.icon)
                            .font(.title3)
                        Text(source.title)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedSource == source ? .blue.opacity(0.2) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .foregroundStyle(selectedSource == source ? .blue : .secondary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Manual Form

    private var manualFormContent: some View {
        Group {
            // Name Section
            sectionCard {
                LabeledTextField("First Name", text: $firstName, icon: "person")
                Divider()
                LabeledTextField("Last Name", text: $lastName, icon: "person")
                Divider()
                Toggle(isOn: $hasCompany) {
                    Label("Company", systemImage: "building.2")
                }
                if hasCompany {
                    LabeledTextField("Company Name", text: $companyName, icon: "building.2")
                }
            }

            // Contact Section
            sectionCard {
                LabeledTextField("Email", text: $email, icon: "envelope", keyboardType: .emailAddress)
                Divider()
                LabeledTextField("Phone", text: $phone, icon: "phone", keyboardType: .phonePad)
                Divider()
                LabeledTextField("Address", text: $address, icon: "mappin.and.ellipse")
            }

            // Details Section
            sectionCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Notes", systemImage: "note.text")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                }
            }
        }
    }

    // MARK: - Google Ads Placeholder

    private var googleAdsPlaceholder: some View {
        sectionCard {
            VStack(spacing: 16) {
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)

                Text("Google Ads Lead Import")
                    .font(.headline)

                Text("Connect your Google Ads account to automatically import leads as clients. Incoming leads will map directly to your client fields.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 4) {
                    Label("Webhook URL", systemImage: "link")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("https://api.base1.app/webhook/google-ads/\(businessManager.businessKey ?? "...")")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Text("Coming Soon")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.blue.gradient)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Squarespace Placeholder

    private var squarespacePlaceholder: some View {
        sectionCard {
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .font(.system(size: 40))
                    .foregroundStyle(.indigo)

                Text("Squarespace Form Integration")
                    .font(.headline)

                Text("Connect your Squarespace website forms to automatically create clients when visitors submit inquiries.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 4) {
                    Label("Webhook URL", systemImage: "link")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("https://api.base1.app/webhook/squarespace/\(businessManager.businessKey ?? "...")")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Text("Coming Soon")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.indigo.gradient)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Section Card

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Save

    private func saveClient() {
        guard let businessKey = businessManager.businessKey else { return }

        let client = Client(
            businessKey: businessKey,
            firstName: firstName,
            lastName: lastName,
            companyName: hasCompany && !companyName.isEmpty ? companyName : nil,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            address: address.isEmpty ? nil : address,
            status: .lead
        )
        client.notes = notes.isEmpty ? nil : notes
        client.business = businessManager.currentBusiness

        modelContext.insert(client)
        dismiss()
    }
}

// MARK: - Client Source

private enum ClientSource: String, CaseIterable, Identifiable {
    case manual
    case googleAds
    case squarespace

    var id: String { rawValue }

    var title: String {
        switch self {
        case .manual: "Manual"
        case .googleAds: "Google Ads"
        case .squarespace: "Squarespace"
        }
    }

    var icon: String {
        switch self {
        case .manual: "person.badge.plus"
        case .googleAds: "megaphone"
        case .squarespace: "globe"
        }
    }
}
