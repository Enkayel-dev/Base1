//
//  AddProjectPhotoView.swift
//  Base1
//
//  Created by Antigravity on 2026-02-12.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddProjectPhotoView: View {
    let project: Project

    @Environment(BusinessManager.self) private var businessManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissDrawer) private var dismiss

    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var caption = ""

    private var canSave: Bool {
        imageData != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Add Site Photo",
                leadingAction: { dismiss() },
                trailingAction: { save() },
                isTrailingDisabled: !canSave
            )

            ScrollView {
                VStack(spacing: 24) {
                    sectionCard {
                        if let imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        self.imageData = nil
                                        self.selectedItem = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white, .black.opacity(0.5))
                                            .font(.title)
                                            .padding(8)
                                    }
                                }
                        } else {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 40))
                                    Text("Select Photo")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
                                .overlay {
                                    RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius)
                                        .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                }
                            }
                        }
                    }

                    sectionCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Caption", systemImage: "text.alignleft")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("Optional description...", text: $caption)
                                .textFieldStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    self.imageData = data
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
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }

    private func save() {
        guard let businessKey = businessManager.businessKey,
              let data = imageData else { return }

        let photo = ProjectPhoto(
            businessKey: businessKey,
            imageData: data,
            caption: caption.isEmpty ? nil : caption
        )
        photo.project = project
        modelContext.insert(photo)

        dismiss()
    }
}
