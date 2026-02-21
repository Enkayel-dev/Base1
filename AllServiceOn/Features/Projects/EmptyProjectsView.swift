//
//  EmptyProjectsView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI

struct EmptyProjectsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No projects")
                .font(.headline)

            Text("Projects matching this filter will appear here.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }
}
