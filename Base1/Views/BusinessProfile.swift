//
//  BusinessProfile.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

struct BusinessProfile: View {

    @Environment(BusinessContext.self) private var businessContext
    @Query private var businesses: [Business]

    private var business: Business? {
        businesses.first(where: { $0.businessKey == businessContext.businessKey })
    }

    var body: some View {
        VStack(spacing: 20) {

            Text("Business Profile")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let business {
                List {
                    Section("Information") {
                        Text(business.name)
                        Text(business.ownerName)
                        Text("Business Key: \(business.businessKey)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            } else {
                Text("No Business Loaded")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}


#Preview {
    ZStack {
        Color.teal.ignoresSafeArea()
        BusinessProfile()
            .environment(TabRouter())
            .environment(BusinessService())
    }
}
