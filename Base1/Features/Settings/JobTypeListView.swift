//
//  JobTypeListView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI
import SwiftData

struct JobTypeListView: View {

    @Environment(BusinessManager.self) private var businessManager
    @Environment(DrawerRouter.self) private var drawerRouter
    @Query(sort: \JobType.sortOrder)
    private var allJobTypes: [JobType]

    private var businessJobTypes: [JobType] {
        guard let key = businessManager.businessKey else { return [] }
        return allJobTypes.filter { $0.businessKey == key }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if businessJobTypes.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No job types yet")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("Create job types to use as project templates")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        ForEach(businessJobTypes) { jobType in
                            Button {
                                drawerRouter.present(.jobTypeDetail(jobType))
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: jobType.icon)
                                        .font(.title3)
                                        .foregroundStyle(.blue)
                                        .frame(width: 36, height: 36)
                                        .background(.blue.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(jobType.name)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text("\(jobType.scopeItemTemplates.count) scope items")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Job Types")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        drawerRouter.present(.addJobType)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }
}
