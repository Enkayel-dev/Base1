//
//  Tab1View.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI
import SwiftData

struct Tab1View: View {
    @State private var selectedFilter: FilterOption = .all
    @State private var clientService = ClientService()
    @State private var showingAddClient = false

    @Environment(BusinessManager.self) private var businessManager

    @Query(sort: \Client.createdAt, order: .reverse)
    private var allClients: [Client]

    var body: some View {
        VStack(spacing: 20) {

            HStack {
                Spacer()
                Text("Clients")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    showingAddClient = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal)

            LiquidGlassFilterPicker(selectedFilter: $selectedFilter)
                .padding(.horizontal)

            let filteredClients = clientService.clients(
                from: allClients,
                filter: selectedFilter
            )

            if filteredClients.isEmpty {
                EmptyClientsView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredClients) { client in
                            ClientRowView(client: client)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()
        }
        .sheet(isPresented: $showingAddClient) {
            AddClientView()
        }
    }
}
