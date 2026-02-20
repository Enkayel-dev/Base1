//
//  ExpandableCard.swift
//  Base1
//
//  Created by Claude on 2026-02-19.
//

import SwiftUI

/// A reusable expandable card component that displays a collapsed header
/// and expands to show full content when tapped.
///
/// Use this component to replace nested drawers with inline expandable forms
/// within a parent ScrollView or drawer.
struct ExpandableCard<Header: View, Content: View>: View {
    @Binding var isExpanded: Bool
    let header: () -> Header
    let content: () -> Content
    
    /// Optional callback when the card is about to expand
    var onExpand: (() -> Void)?
    /// Optional callback when the card is about to collapse
    var onCollapse: (() -> Void)?
    
    init(
        isExpanded: Binding<Bool>,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content,
        onExpand: (() -> Void)? = nil,
        onCollapse: (() -> Void)? = nil
    ) {
        self._isExpanded = isExpanded
        self.header = header
        self.content = content
        self.onExpand = onExpand
        self.onCollapse = onCollapse
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Collapsed header - always visible, tappable to toggle
            Button {
                toggleExpansion()
            } label: {
                HStack {
                    header()
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Expanded content - conditionally visible with animation
            if isExpanded {
                Divider()
                    .padding(.vertical, 12)
                
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
    }
    
    private func toggleExpansion() {
        if isExpanded {
            onCollapse?()
        } else {
            onExpand?()
        }
        
        withAnimation(.spring(
            response: DesignConstants.Animation.morphResponse,
            dampingFraction: DesignConstants.Animation.morphDamping
        )) {
            isExpanded.toggle()
        }
    }
}

// MARK: - Convenience Initializer for Add Actions

extension ExpandableCard where Header == ExpandableCardAddHeader {
    /// Creates an expandable card with a standard "Add" header style.
    ///
    /// - Parameters:
    ///   - title: The title to display (e.g., "Add Measurement")
    ///   - icon: The SF Symbol name for the icon
    ///   - isExpanded: Binding to control expansion state
    ///   - content: The content to show when expanded
    init(
        title: String,
        icon: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        onExpand: (() -> Void)? = nil,
        onCollapse: (() -> Void)? = nil
    ) {
        self._isExpanded = isExpanded
        self.header = { ExpandableCardAddHeader(title: title, icon: icon) }
        self.content = content
        self.onExpand = onExpand
        self.onCollapse = onCollapse
    }
}

/// Standard header for add-style expandable cards
struct ExpandableCardAddHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        Label(title, systemImage: icon)
            .font(.subheadline)
            .fontWeight(.medium)
    }
}

// MARK: - Preview

#Preview("Collapsed") {
    @Previewable @State var isExpanded = false
    
    ExpandableCard(
        title: "Add Measurement",
        icon: "ruler",
        isExpanded: $isExpanded
    ) {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Name", text: .constant("Living Room"))
            TextField("Value", text: .constant("150"))
            Button("Save") { }
                .buttonStyle(.borderedProminent)
        }
    }
    .padding()
}

#Preview("Expanded") {
    @Previewable @State var isExpanded = true
    
    ExpandableCard(
        title: "Add Measurement",
        icon: "ruler",
        isExpanded: $isExpanded
    ) {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Name", text: .constant("Living Room"))
            TextField("Value", text: .constant("150"))
            Button("Save") { }
                .buttonStyle(.borderedProminent)
        }
    }
    .padding()
}
