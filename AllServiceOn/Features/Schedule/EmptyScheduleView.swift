//
//  EmptyScheduleView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

struct EmptyScheduleView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No appointments")
                .font(.headline)

            Text("Appointments matching this filter will appear here.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }
}
