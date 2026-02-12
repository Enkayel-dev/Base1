//
//  MemberRowView.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-11.
//

import SwiftUI

struct MemberRowView: View {

    let member: Member

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Text(member.initials)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(avatarColor.gradient)
                .clipShape(Circle())

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(member.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 6) {
                    Text(member.email)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let rate = member.hourlyRate {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(rate as NSDecimalNumber)/hr")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Status + Role
            VStack(alignment: .trailing, spacing: 4) {
                Text(member.role.displayTitle)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(roleBadgeColor.gradient)
                    .clipShape(Capsule())

                if member.inviteStatus == .pending {
                    Text("Pending")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var avatarColor: Color {
        switch member.role {
        case .owner: .blue
        case .admin: .purple
        case .member: .gray
        }
    }

    private var roleBadgeColor: Color {
        switch member.role {
        case .owner: .blue
        case .admin: .purple
        case .member: .gray
        }
    }
}
