//
//  LiquidGlassFilterPicker.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

struct LiquidGlassFilterPicker: View {
    @Binding var selectedFilter: FilterOption
    @Namespace private var glassNS
    
    var body: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(FilterOption.allCases) { filter in
                    filterButton(for: filter)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(6)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    @ViewBuilder
    private func filterButton(for filter: FilterOption) -> some View {
        let isSelected = selectedFilter == filter
        
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedFilter = filter
            }
        } label: {
            Text(filter.title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(.blue.gradient)
                            .matchedGeometryEffect(id: "selection", in: glassNS)
                    }
                }
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .glassEffectID(filter.id, in: glassNS)
    }
}

// MARK: - Filter Option Model

enum FilterOption: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Lead"
    case pending = "Active"
    case completed = "Closed"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedFilter: FilterOption = .all
        
        var body: some View {
            ZStack {
                AnimatedMeshBackground()
                
                VStack(spacing: 20) {
                    Text("Selected: \(selectedFilter.title)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    LiquidGlassFilterPicker(selectedFilter: $selectedFilter)
                }
                .padding()
            }
            .ignoresSafeArea()
        }
    }
    
    return PreviewWrapper()
        .preferredColorScheme(.dark)
}
