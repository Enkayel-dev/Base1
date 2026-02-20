//
//  SubscriptionManager.swift
//  Base1
//
//  Manages StoreKit 2 subscriptions for the app.
//

import SwiftUI
import StoreKit

/// Subscription tier levels
enum SubscriptionTier: String, CaseIterable, Sendable {
    case none
    case basic
    case professional
    case enterprise
    
    var displayName: String {
        switch self {
        case .none: return "Free"
        case .basic: return "Basic"
        case .professional: return "Professional"
        case .enterprise: return "Enterprise"
        }
    }
    
    var maxTeamMembers: Int {
        switch self {
        case .none: return 0
        case .basic: return 3
        case .professional: return 10
        case .enterprise: return .max
        }
    }
    
    var features: [String] {
        switch self {
        case .none:
            return ["Single user", "Basic project tracking"]
        case .basic:
            return ["Up to 3 team members", "Project estimates", "Basic scheduling"]
        case .professional:
            return ["Up to 10 team members", "Advanced estimates", "Full scheduling", "Client portal"]
        case .enterprise:
            return ["Unlimited team members", "All features", "Priority support", "Custom branding"]
        }
    }
}

/// Subscription status info
struct SubscriptionStatus: Sendable {
    let tier: SubscriptionTier
    let isActive: Bool
    let expirationDate: Date?
    let willAutoRenew: Bool
    let productID: String?
}

/// Service for managing StoreKit 2 subscriptions
@MainActor @Observable
final class SubscriptionManager {
    
    // MARK: - State
    
    private(set) var subscriptionStatus: SubscriptionStatus = SubscriptionStatus(
        tier: .none,
        isActive: false,
        expirationDate: nil,
        willAutoRenew: false,
        productID: nil
    )
    
    private(set) var availableProducts: [Product] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    
    // MARK: - Product IDs
    
    /// Product identifiers configured in App Store Connect
    private let productIDs: Set<String> = [
        "com.base1.subscription.basic.monthly",
        "com.base1.subscription.basic.yearly",
        "com.base1.subscription.professional.monthly",
        "com.base1.subscription.professional.yearly",
        "com.base1.subscription.enterprise.monthly",
        "com.base1.subscription.enterprise.yearly"
    ]
    
    /// Subscription group identifier
    private let subscriptionGroupID = "com.base1.subscriptions"
    
    // MARK: - Transaction Listener
    
    private var transactionListenerTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init() {
        // Start listening for transactions
        startTransactionListener()
        
        // Load products and check status
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    /// Stop listening for transactions
    func stopListening() {
        transactionListenerTask?.cancel()
        transactionListenerTask = nil
    }
    
    // MARK: - Public API
    
    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let products = try await Product.products(for: productIDs)
            
            // Sort by price
            availableProducts = products.sorted { $0.price < $1.price }
            error = nil
        } catch {
            self.error = error
            availableProducts = []
        }
    }
    
    /// Purchase a subscription product
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try Self.checkVerified(verification)
            
            // Update subscription status
            await updateSubscriptionStatus()
            
            // Finish the transaction
            await transaction.finish()
            
            return transaction
            
        case .pending:
            // Transaction waiting for approval (Ask to Buy, etc.)
            return nil
            
        case .userCancelled:
            // User cancelled, not an error
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    /// Restore previous purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            self.error = error
        }
    }
    
    /// Update current subscription status
    func updateSubscriptionStatus() async {
        var foundSubscription = false
        
        // Check all current entitlements
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try Self.checkVerified(result)
                
                // Check if this is one of our subscription products
                if productIDs.contains(transaction.productID) {
                    let tier = tierForProductID(transaction.productID)
                    
                    // Check if subscription is active based on expiration
                    let isActive = transaction.expirationDate.map { $0 > Date.now } ?? false
                    
                    subscriptionStatus = SubscriptionStatus(
                        tier: tier,
                        isActive: isActive,
                        expirationDate: transaction.expirationDate,
                        willAutoRenew: transaction.revocationDate == nil,
                        productID: transaction.productID
                    )
                    foundSubscription = true
                    break
                }
            } catch {
                // Skip invalid transactions
                continue
            }
        }
        
        if !foundSubscription {
            subscriptionStatus = SubscriptionStatus(
                tier: .none,
                isActive: false,
                expirationDate: nil,
                willAutoRenew: false,
                productID: nil
            )
        }
    }
    
    /// Check if user has active subscription
    var hasActiveSubscription: Bool {
        subscriptionStatus.isActive && subscriptionStatus.tier != .none
    }
    
    /// Current subscription tier
    var currentTier: SubscriptionTier {
        subscriptionStatus.tier
    }
    
    /// Check if user can add more team members
    func canAddTeamMember(currentCount: Int) -> Bool {
        currentCount < subscriptionStatus.tier.maxTeamMembers
    }
    
    // MARK: - Private Methods
    
    /// Start listening for transaction updates
    private func startTransactionListener() {
        transactionListenerTask = Task {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try Self.checkVerified(result)
                    
                    // Update status
                    await self.updateSubscriptionStatus()
                    
                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    // Log but don't crash
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    /// Verify a transaction (static to avoid actor isolation issues)
    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw SubscriptionError.verificationFailed(error)
        case .verified(let safe):
            return safe
        }
    }
    
    /// Map product ID to subscription tier
    private func tierForProductID(_ productID: String) -> SubscriptionTier {
        if productID.contains("basic") {
            return .basic
        } else if productID.contains("professional") {
            return .professional
        } else if productID.contains("enterprise") {
            return .enterprise
        }
        return .none
    }
    
    /// Get products for a specific tier
    func products(for tier: SubscriptionTier) -> [Product] {
        availableProducts.filter { product in
            tierForProductID(product.id) == tier
        }
    }
    
    /// Get monthly product for a tier
    func monthlyProduct(for tier: SubscriptionTier) -> Product? {
        products(for: tier).first { $0.id.contains("monthly") }
    }
    
    /// Get yearly product for a tier
    func yearlyProduct(for tier: SubscriptionTier) -> Product? {
        products(for: tier).first { $0.id.contains("yearly") }
    }
}

// MARK: - Subscription Errors

enum SubscriptionError: LocalizedError {
    case verificationFailed(Error)
    case purchaseFailed
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .verificationFailed(let error):
            return "Verification failed: \(error.localizedDescription)"
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        case .productNotFound:
            return "Product not found"
        }
    }
}
