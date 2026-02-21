//
//  AppointmentRowView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

struct AppointmentRowView: View {
    let appointment: Appointment

    private var timeText: String {
        if appointment.isAllDay {
            return "All Day"
        }
        return "\(appointment.startDate.formatted(date: .omitted, time: .shortened)) – \(appointment.endDate.formatted(date: .omitted, time: .shortened))"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            Image(systemName: appointment.type.systemImage)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(iconColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.title)
                    .font(.headline)
                    .strikethrough(appointment.isCancelled)
                    .foregroundStyle(appointment.isCancelled ? .secondary : .primary)

                Text(timeText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let clientName = appointment.client?.displayName {
                    Label(clientName, systemImage: "person")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let location = appointment.location, !location.isEmpty {
                    Label(location, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if appointment.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if appointment.isCancelled {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }

    private var iconColor: Color {
        switch appointment.type {
        case .consultation: .blue
        case .siteVisit: .orange
        case .meeting: .purple
        case .followUp: .teal
        case .delivery: .green
        }
    }
}
