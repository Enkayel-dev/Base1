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

                        // MARK: - Notes
                        sectionCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Notes", systemImage: "note.text")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                TextEditor(text: $business.notes.orEmpty)
                                    .frame(minHeight: 100)
                                    .scrollContentBackground(.hidden)
                            }
                        }

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

    // MARK: - Section Card

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
