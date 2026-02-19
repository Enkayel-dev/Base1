//
//  BusinessProfile.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct BusinessProfile: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(DrawerRouter.self) private var drawerRouter
    @State private var selectedPhoto: PhotosPickerItem?

    private var business: Business? {
        businessManager.currentBusiness
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Business Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            if let business {
                @Bindable var business = business

                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Logo
                        logoSection(business: business)

                        // MARK: - Business Info
                        sectionCard {
                            LabeledTextField("Business Name", text: $business.name, icon: "building.2")
                            Divider()
                            LabeledTextField("Owner Name", text: $business.ownerName, icon: "person")
                        }

                        // MARK: - Contact
                        sectionCard {
                            LabeledTextField("Email", text: $business.email.orEmpty, icon: "envelope", keyboardType: .emailAddress)
                            Divider()
                            LabeledTextField("Phone", text: $business.phone.orEmpty, icon: "phone", keyboardType: .phonePad)
                            Divider()
                            LabeledTextField("Address", text: $business.address.orEmpty, icon: "mappin.and.ellipse")
                            Divider()
                            LabeledTextField("Tax No.", text: $business.taxNumber.orEmpty, icon: "number")
                        }

                        // MARK: - Pricing
                        sectionCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Pricing", systemImage: "percent")
                                    .font(.headline)

                                TextField("0", value: Binding(
                                    get: { business.costMarkupPercentage ?? Decimal.zero },
                                    set: { business.costMarkupPercentage = $0 > 0 ? $0 : nil }
                                ), format: .number)
                                .keyboardType(.decimalPad)
                                .font(.title3)
                                .fontWeight(.semibold)

                                Text("Cost markup percentage applied to all project estimates")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // MARK: - Team
                        teamSection(business: business)


                        // MARK: - Business Key
                        VStack(spacing: 4) {
                            Text("Business Key")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(business.businessKey)
                                .font(.footnote.monospaced())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
            }
        }
    }

    // MARK: - Team Section

    @ViewBuilder
    private func teamSection(business: Business) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Team", systemImage: "person.3")
                    .font(.headline)

                Text("\(business.members.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    drawerRouter.present(.inviteMember)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
            }

            let sortedMembers = business.members.sorted { m1, m2 in
                let order: [MemberRole] = [.owner, .admin, .member]
                let i1 = order.firstIndex(of: m1.role) ?? 2
                let i2 = order.firstIndex(of: m2.role) ?? 2
                return i1 < i2
            }

            if sortedMembers.isEmpty {
                Text("No team members yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sortedMembers.enumerated()), id: \.element.id) { index, member in
                        MemberRowView(member: member)
                            .onTapGesture { acceptInviteIfPending(member) }
                        if index < sortedMembers.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            }
        }
    }


    // MARK: - Logo Section

    @ViewBuilder
    private func logoSection(business: Business) -> some View {
        @Bindable var business = business

        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            Group {
                if let logoData = business.logoData,
                   let uiImage = UIImage(data: logoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "building.2.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(20)
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.white.opacity(0.3), lineWidth: 2)
            )
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "camera.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .background(Circle().fill(.ultraThinMaterial).frame(width: 28, height: 28))
            }
        }
        .onChange(of: selectedPhoto) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    business.logoData = data
                }
            }
        }
    }

    // MARK: - Actions

    private func acceptInviteIfPending(_ member: Member) {
        guard member.inviteStatus == .pending else { return }
        member.inviteStatus = .accepted
        member.acceptedAt = .now
        member.updatedAt = .now
    }

    // MARK: - Section Card

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }
}
