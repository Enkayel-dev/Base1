//
//  ClientRowView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

struct ClientRowView: View {
    let client: Client

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(client.displayName)
                    .font(.headline)

                Text(client.status.displayTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
