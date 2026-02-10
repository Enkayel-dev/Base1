//import Observation
import SwiftData

@Observable
final class BusinessContext {
    private(set) var businessKey: String

    init(container: ModelContainer) {
        if let existing = Self.loadBusinessKey(container: container) {
            self.businessKey = existing
        } else {
            let newKey = Self.generateBusinessKey()
            self.businessKey = newKey
            Self.bootstrapBusiness(container: container, businessKey: newKey)
        }
    }

    // MARK: - Fetch existing business key
    private static func loadBusinessKey(container: ModelContainer) -> String? {
        let descriptor = FetchDescriptor<Business>()
        return try? container.mainContext.fetch(descriptor).first?.businessKey
    }

    // MARK: - Create new business if none exists
    private static func bootstrapBusiness(container: ModelContainer, businessKey: String) {
        let business = Business(
            businessKey: businessKey, // ✅ required now
            name: "My Business",
            ownerName: "Owner"
        )

        // Insert into context and save
        container.mainContext.insert(business)   // just call normally
        try? container.mainContext.save()        // only save needs try
    }

    // MARK: - Generate unique key
    private static func generateBusinessKey() -> String {
        let charset = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return "BUS_" + String((0..<8).compactMap { _ in charset.randomElement() })
    }
}
