//
//  DrawerHeader.swift
//  Base1
//
//  Created by Antigravity on 2026-02-12.
//

import SwiftUI

struct DrawerHeader: View {
    let title: String
    var leadingText: String? = "Cancel"
    var leadingAction: (() -> Void)?
    var trailingText: String? = "Save"
    var trailingAction: (() -> Void)?
    var isTrailingDisabled: Bool = false

    var body: some View {
        HStack {
            if let leadingAction = leadingAction {
                Button(leadingText ?? "Cancel") {
                    leadingAction()
                }
                .font(.body)
                .foregroundStyle(Color.blue)
            } else {
                Spacer()
                    .frame(width: 60)
            }

            Spacer()

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            if let trailingAction = trailingAction {
                Button(trailingText ?? "Save") {
                    trailingAction()
                }
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(isTrailingDisabled ? .secondary : Color.blue)
                .disabled(isTrailingDisabled)
            } else {
                Spacer()
                    .frame(width: 60)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.clear)
    }
}
