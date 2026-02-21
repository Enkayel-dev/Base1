//
//  ClientDetailView.swift
//  Base1
//
//  Created by Antigravity on 2026-02-11.
//

import SwiftUI
import SwiftData

struct ClientDetailView: View {
    let client: Client
    
    @Environment(\.dismissDrawer) private var dismiss

    private var sortedProjects: [Project] {
        client.projects.sorted { $0.createdAt > $1.createdAt }
    }

    private var sortedAppointments: [Appointment] {
        client.appointments.sorted { $0.startDate > $1.startDate }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Client Detail",
                leadingText: "Back",
                leadingAction: { dismiss() },
                trailingText: "Done",
                trailingAction: { dismiss() }
            )

            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    contactSection
                    
                    if let notes = client.notes, !notes.isEmpty {
                        notesSection(notes)
                    }
                    
                    projectsSection
                    
                    appointmentsSection
                }
                .padding()
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(client.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 8) {
                    if let company = client.companyName, !company.isEmpty {
                        Text(company)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(client.status.displayTitle)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor.gradient)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }
    
    // MARK: - Contact Section
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Information")
                .font(.headline)
            
            VStack(spacing: 0) {
                if let email = client.email, !email.isEmpty {
                    contactRow(icon: "envelope.fill", label: "Email", value: email, action: {
                        if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                        }
                    })
                    if client.phone != nil || client.address != nil { Divider() }
                }
                
                if let phone = client.phone, !phone.isEmpty {
                    contactRow(icon: "phone.fill", label: "Phone", value: phone, action: {
                        let cleanedPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        if let url = URL(string: "tel:\(cleanedPhone)") {
                            UIApplication.shared.open(url)
                        }
                    })
                    if client.address != nil { Divider() }
                }
                
                if let address = client.address, !address.isEmpty {
                    contactRow(icon: "mappin.and.ellipse", label: "Address", value: address, action: {
                        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "http://maps.apple.com/?address=\(encodedAddress)") {
                            UIApplication.shared.open(url)
                        }
                    })
                }
            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
        }
    }
    
    private func contactRow(icon: String, label: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
    }
    
    // MARK: - Notes Section
    
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            
            Text(notes)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
        }
    }
    
    // MARK: - Projects Section
    
    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Projects")
                .font(.headline)
            
            if client.projects.isEmpty {
                Text("No linked projects")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            } else {
                ForEach(sortedProjects) { project in
                    ProjectRowView(project: project)
                }
            }
        }
    }
    
    // MARK: - Appointments Section
    
    private var appointmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appointments")
                .font(.headline)
            
            if client.appointments.isEmpty {
                Text("No linked appointments")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            } else {
                ForEach(sortedAppointments) { appointment in
                    AppointmentRowView(appointment: appointment)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var statusColor: Color {
        switch client.status {
        case .lead: .blue
        case .active: .green
        case .closed: .gray
        }
    }
}
