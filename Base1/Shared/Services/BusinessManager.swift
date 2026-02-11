import SwiftUI
import SwiftData
import Observation


@MainActor @Observable
final class BusinessManager {

    // MARK: - Shared state
    private(set) var currentBusiness: Business?
    private(set) var businessKey: String?   // ✅ must be var, not let

    private let context: ModelContext

    // MARK: - Init
    init(container: ModelContainer) {
        self.context = container.mainContext
        loadOrBootstrapBusiness()
    }

    // MARK: - Public API
    func business(forAppleUserID appleUserID: String) -> Business? {
        if let business = currentBusiness, business.ownerAppleUserID == appleUserID {
            return business
        }
        loadOrCreateBusiness(appleUserID: appleUserID)
        return currentBusiness
    }

    // MARK: - Fetch or bootstrap
    private func loadOrBootstrapBusiness() {
        do {
            if let existing = try context.fetch(FetchDescriptor<Business>()).first {
                currentBusiness = existing
                businessKey = existing.businessKey
            } else {
                let newKey = generateBusinessKey()
                businessKey = newKey
                bootstrapBusiness(businessKey: newKey)
            }
        } catch {
            print("Failed to fetch Business during bootstrap: \(error)")
        }
    }

    private func loadOrCreateBusiness(appleUserID: String) {
        let descriptor = FetchDescriptor<Business>(
            predicate: #Predicate { $0.ownerAppleUserID == appleUserID }
        )

        do {
            if let existing = try context.fetch(descriptor).first {
                currentBusiness = existing
                businessKey = existing.businessKey
                return
            }
        } catch {
            print("Failed to fetch Business by Apple ID: \(error)")
        }

        let newKey = generateBusinessKey()
        let business = Business(
            businessKey: newKey,
            ownerAppleUserID: appleUserID,
            name: "My Business",
            ownerName: "Owner"
        )

        context.insert(business)

        do {
            try context.save()
        } catch {
            print("Failed to save new Business: \(error)")
        }

        currentBusiness = business
        businessKey = newKey
    }

    private func bootstrapBusiness(businessKey: String) {
        let placeholderAppleID = "UNKNOWN_APPLE_USER"

        let business = Business(
            businessKey: businessKey,
            ownerAppleUserID: placeholderAppleID,
            name: "My Business",
            ownerName: "Owner"
        )

        context.insert(business)

        do {
            try context.save()
        } catch {
            print("Failed to bootstrap Business: \(error)")
        }

        currentBusiness = business
        self.businessKey = businessKey
    }

    private func generateBusinessKey() -> String {
        let charset = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return "BUS_" + String((0..<8).compactMap { _ in charset.randomElement() })
    }
}
