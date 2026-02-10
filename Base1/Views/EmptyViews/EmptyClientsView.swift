//
//  Untitled.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

struct EmptyClientsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No clients")
                .font(.headline)

            Text("Clients matching this status will appear here.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }
}
