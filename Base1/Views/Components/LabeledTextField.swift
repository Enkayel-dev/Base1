//
//  LabeledTextField.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import UIKit

struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default

    init(_ label: String, text: Binding<String>, icon: String, keyboardType: UIKeyboardType = .default) {
        self.label = label
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(label, text: $text)
                .keyboardType(keyboardType)
        }
    }
}
