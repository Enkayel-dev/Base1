//
//  BusinessService.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

@Observable
final class BusinessService {

    private(set) var currentBusiness: Business?
    private(set) var currentBusinessKey: String?

    func loadOrCreateBusiness(
        appleUserID: String,
        context: ModelContext
    ) throws {

        let descriptor = FetchDescriptor<Business>(
            predicate: #Predicate { $0.ownerAppleUserID == appleUserID }
        )

        if let existing = try context.fetch(descriptor).first {
            currentBusiness = existing
            currentBusinessKey = existing.businessKey
            return
        }

        let newKey = BusinessKeyGenerator.generate()
        let business = Business(
            businessKey: newKey,
            ownerAppleUserID: appleUserID,
            name: "My Business",
            ownerName: "Owner"
        )

        context.insert(business)
        try context.save()

        currentBusiness = business
        currentBusinessKey = newKey
    }
}
