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
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    private var content: AnyView

    init(_ label: String, text: Binding<String>, icon: String, keyboardType: UIKeyboardType = .default) {
        self.label = label
        self.icon = icon
        self.keyboardType = keyboardType
        self.content = AnyView(
            TextField(label, text: text)
                .keyboardType(keyboardType)
        )
    }
    
    // Generic initializer for value + format
    init<V, F>(_ label: String, value: Binding<V>, icon: String, format: F, keyboardType: UIKeyboardType = .decimalPad) where V : Equatable, F : ParseableFormatStyle, V == F.FormatInput, F.FormatOutput == String {
        self.label = label
        self.icon = icon
        self.keyboardType = keyboardType
        self.content = AnyView(
            TextField(label, value: value, format: format)
                .keyboardType(keyboardType)
        )
    }
    
    // Specialized initializer for optional Decimal with currency formatting
    // This solves the common case in the app where hourlyRate is Decimal?
    init(_ label: String, value: Binding<Decimal?>, icon: String, format: Decimal.FormatStyle.Currency, keyboardType: UIKeyboardType = .decimalPad) {
        self.label = label
        self.icon = icon
        self.keyboardType = keyboardType
        self.content = AnyView(
            TextField(label, value: value, format: format)
                .keyboardType(keyboardType)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            content
        }
    }
}
