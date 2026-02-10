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

    @Query(sort: \Client.createdAt, order: .reverse)
    private var allClients: [Client]

    var body: some View {
        VStack(spacing: 20) {

            Text("Clients")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)

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
    }
}
