//
//  BusinessProfile.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData
import Observation

struct BusinessProfile: View {
    
    // Use the new combined manager
    @Environment(BusinessManager.self) private var businessManager
    
    // Computed property to get the current business
    private var business: Business? {
        businessManager.currentBusiness
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Business Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            if let business {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text("Name: \(business.name)")
                            Text("Owner: \(business.ownerName)")
                            Text("Business Key: \(business.businessKey)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text("Apple ID: \(business.ownerAppleUserID)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        if let email = business.email {
                            Text("Email: \(email)")
                        }
                        if let phone = business.phone {
                            Text("Phone: \(phone)")
                        }
                        if let address = business.address {
                            Text("Address: \(address)")
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
