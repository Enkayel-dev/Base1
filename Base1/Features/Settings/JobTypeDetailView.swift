//
//  JobTypeDetailView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct JobTypeDetailView: View {

    let jobType: JobType

    @State private var showingAddTemplate = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Header
                    HStack(spacing: 12) {
                        Image(systemName: jobType.icon)
                            .font(.title2)
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                            .background(.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Text(jobType.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Scope Item Templates
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Scope Items")
                                .font(.headline)

                            Spacer()

                            Button {
                                showingAddTemplate = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }

                        if jobType.scopeItemTemplates.isEmpty {
                            Text("No scope items yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            ForEach(jobType.scopeItemTemplates) { template in
                                scopeTemplateRow(template)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Job Type")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddTemplate) {
                AddScopeItemTemplateView(jobType: jobType)
            }
        }
    }

    private func scopeTemplateRow(_ template: ScopeItemTemplate) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    if let resource = template.resource {
                        Label(resource.name, systemImage: "cube.box")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text("Qty: \(template.defaultQuantity)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let hours = template.defaultLaborHours {
                        Text("\(hours as NSDecimalNumber)h")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
