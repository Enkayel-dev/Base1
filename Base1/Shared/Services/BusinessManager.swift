import SwiftUI
import SwiftData
import Observation


@MainActor @Observable
final class BusinessManager {

    // MARK: - Shared state
    private(set) var currentBusiness: Business?
    private(set) var businessKey: String?   // ✅ must be var, not let
    
    /// The currently logged-in member (for role-based access)
    private(set) var currentMember: Member?
    
    /// Whether the user is the business owner (authenticated via Sign in with Apple)
    private(set) var isBusinessOwner = false
    
    /// Debug mode: allows switching roles without authentication
    var debugModeEnabled = false
    var debugSelectedMember: Member?

    private let context: ModelContext
    
    // MARK: - Role Helpers
    
    /// Returns the current user's role, defaulting to owner if no member is set
    var currentUserRole: MemberRole {
        // In debug mode, use the selected debug member
        if debugModeEnabled, let debugMember = debugSelectedMember {
            return debugMember.role
        }
        return currentMember?.role ?? .owner
    }
    
    /// Returns true if the current user is an owner or admin
    var isOwnerOrAdmin: Bool {
        currentUserRole == .owner || currentUserRole == .admin
    }
    
    /// Returns the effective current member (debug or real)
    var effectiveCurrentMember: Member? {
        if debugModeEnabled {
            return debugSelectedMember
        }
        return currentMember
    }
    
    /// Sets the current member (call this when user signs in or for testing)
    func setCurrentMember(_ member: Member?) {
        currentMember = member
    }
    
    /// Configure business manager with authenticated user
    func configureForAuthenticatedUser(appleUserID: String, credentials: AppleUserCredentials?) {
        // Try to find existing business for this user
        let descriptor = FetchDescriptor<Business>(
            predicate: #Predicate { $0.ownerAppleUserID == appleUserID }
        )
        
        do {
            if let existing = try context.fetch(descriptor).first {
                // User owns this business
                currentBusiness = existing
                businessKey = existing.businessKey
                isBusinessOwner = true
                
                // Find or create owner member
                findOrCreateOwnerMember(for: existing, credentials: credentials)
            } else {
                // Check if user is a team member in any business
                let memberDescriptor = FetchDescriptor<Member>(
                    predicate: #Predicate { $0.appleUserID == appleUserID }
                )
                
                if let member = try context.fetch(memberDescriptor).first,
                   let business = member.business {
                    // User is a team member
                    currentBusiness = business
                    businessKey = business.businessKey
                    currentMember = member
                    isBusinessOwner = false
                } else {
                    // New user - create new business
                    createNewBusiness(for: appleUserID, credentials: credentials)
                    isBusinessOwner = true
                }
            }
        } catch {
            print("Failed to configure for authenticated user: \(error)")
        }
    }
    
    /// Create a new business for a first-time user
    private func createNewBusiness(for appleUserID: String, credentials: AppleUserCredentials?) {
        let newKey = generateBusinessKey()
        let ownerName = credentials?.displayName ?? "Owner"
        
        let business = Business(
            businessKey: newKey,
            ownerAppleUserID: appleUserID,
            name: "My Business",
            ownerName: ownerName
        )
        
        context.insert(business)
        
        // Create owner member
        let ownerMember = Member(
            businessKey: newKey,
            email: credentials?.email ?? "",
            displayName: ownerName,
            role: .owner,
            inviteStatus: .accepted
        )
        ownerMember.appleUserID = appleUserID
        ownerMember.acceptedAt = .now
        ownerMember.business = business
        
        context.insert(ownerMember)
        
        do {
            try context.save()
        } catch {
            print("Failed to create new business: \(error)")
        }
        
        currentBusiness = business
        businessKey = newKey
        currentMember = ownerMember
    }
    
    /// Find or create owner member for existing business
    private func findOrCreateOwnerMember(for business: Business, credentials: AppleUserCredentials?) {
        let businessKeyValue = business.businessKey
        let ownerRoleValue = MemberRole.owner.rawValue
        let descriptor = FetchDescriptor<Member>(
            predicate: #Predicate { member in
                member.businessKey == businessKeyValue &&
                member.roleRaw == ownerRoleValue
            }
        )
        
        do {
            if let ownerMember = try context.fetch(descriptor).first {
                currentMember = ownerMember
                
                // Update owner info if needed
                if ownerMember.appleUserID == nil {
                    ownerMember.appleUserID = business.ownerAppleUserID
                    try context.save()
                }
            } else {
                // Create owner member
                let ownerMember = Member(
                    businessKey: business.businessKey,
                    email: credentials?.email ?? "",
                    displayName: credentials?.displayName ?? business.ownerName,
                    role: .owner,
                    inviteStatus: .accepted
                )
                ownerMember.appleUserID = business.ownerAppleUserID
                ownerMember.acceptedAt = .now
                ownerMember.business = business
                
                context.insert(ownerMember)
                try context.save()
                
                currentMember = ownerMember
            }
        } catch {
            print("Failed to find/create owner member: \(error)")
        }
    }
    
    /// Sign out and clear state
    func signOut() {
        currentMember = nil
        isBusinessOwner = false
        debugModeEnabled = false
        debugSelectedMember = nil
        // Keep business loaded for potential re-auth
    }

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
