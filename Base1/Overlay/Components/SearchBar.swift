//
//  SearchBar.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct SearchBar: View {
    @Environment(SearchState.self) private var searchState
    @FocusState private var isFocused: Bool
    
    var body: some View {
        @Bindable var search = searchState
        
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.body)
            
            TextField("Search", text: $search.text)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .submitLabel(.search)
            
            if !searchState.text.isEmpty {
                Button {
                    searchState.clearText()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onAppear {
            isFocused = true
        }
    }
}
