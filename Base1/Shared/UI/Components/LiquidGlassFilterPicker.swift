//
//  LiquidGlassFilterPicker.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

// MARK: - Filterable Protocol

protocol Filterable: CaseIterable, Identifiable, Hashable where AllCases: RandomAccessCollection {
    var title: String { get }
}

// MARK: - Liquid Glass Filter Picker

struct LiquidGlassFilterPicker<Filter: Filterable>: View {
    @Binding var selectedFilter: Filter
    @Namespace private var glassNS

    var body: some View {
        let filters = Array(Filter.allCases)
        let topRow = filters.indices.filter { $0 % 2 == 0 }.map { filters[$0] }
        let bottomRow = filters.indices.filter { $0 % 2 != 0 }.map { filters[$0] }

        GlassEffectContainer(spacing: 8) {
            VStack(spacing: 4) {
                // Top Row (Even indices: 0, 2, 4...)
                HStack(spacing: 8) {
                    ForEach(topRow) { filter in
                        filterButton(for: filter)
                    }
                }
                .padding(.horizontal, 6)
                
                // Bottom Row (Odd indices: 1, 3, 5...)
                HStack(spacing: 8) {
                    ForEach(bottomRow) { filter in
                        filterButton(for: filter)
                    }
                }
                .padding(.horizontal, 6)
            }
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    @ViewBuilder
    private func filterButton(for filter: Filter) -> some View {
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

// MARK: - Client Filter Option

enum FilterOption: String, CaseIterable, Identifiable, Filterable {
    case all = "All"
    case lead = "Lead"
    case active = "Active"
    case closed = "Closed"

    var id: String { rawValue }
    var title: String { rawValue }
}

// MARK: - Project Filter Option

enum ProjectFilterOption: String, CaseIterable, Identifiable, Filterable {
    case all = "All"
    case planning = "Planning"
    case inProgress = "Active"
    case onHold = "On Hold"
    case completed = "Done"
    case templates = "Templates"

    var id: String { rawValue }
    var title: String { rawValue }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedFilter: FilterOption = .all
        
        var body: some View {
            ZStack {
                
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
