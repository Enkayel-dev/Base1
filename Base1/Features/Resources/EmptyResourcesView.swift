//
//  EmptyResourcesView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI

struct EmptyResourcesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No resources")
                .font(.headline)

            Text("Resources matching this category will appear here.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }
}
