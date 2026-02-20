//
//  SubscriptionView.swift
//  Base1
//
//  Subscription management and purchase UI using StoreKit 2.
//

import SwiftUI
import StoreKit

/// View for displaying and purchasing subscriptions
struct SubscriptionView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTier: SubscriptionTier = .professional
    @State private var isYearly = true
    @State private var showingError = false
    @State private var purchaseTask: Task<Void, Never>?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current status
                    if subscriptionManager.hasActiveSubscription {
                        currentSubscriptionCard
                    }
                    
                    // Billing toggle
                    billingToggle
                    
                    // Tier cards
                    ForEach(SubscriptionTier.allCases.filter { $0 != .none }, id: \.self) { tier in
                        TierCard(
                            tier: tier,
                            isSelected: selectedTier == tier,
                            isYearly: isYearly,
                            monthlyProduct: subscriptionManager.monthlyProduct(for: tier),
                            yearlyProduct: subscriptionManager.yearlyProduct(for: tier)
                        ) {
                            selectedTier = tier
                        }
                    }
                    
                    // Subscribe button
                    subscribeButton
                    
                    // Restore purchases
                    Button("Restore Purchases") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    
                    // Terms
                    termsText
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = subscriptionManager.error {
                    Text(error.localizedDescription)
                }
            }
            .overlay {
                if subscriptionManager.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
        }
    }
    
    // MARK: - Current Subscription
    
    private var currentSubscriptionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                Text(subscriptionManager.currentTier.displayName)
                    .fontWeight(.semibold)
                Spacer()
                if subscriptionManager.subscriptionStatus.willAutoRenew {
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .cornerRadius(4)
                }
            }
            
            if let expiration = subscriptionManager.subscriptionStatus.expirationDate {
                Text("Renews \(expiration.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Billing Toggle
    
    private var billingToggle: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation { isYearly = false }
            } label: {
                Text("Monthly")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isYearly ? Color.clear : Color.accentColor)
                    .foregroundStyle(isYearly ? Color.secondary : Color.white)
            }
            
            Button {
                withAnimation { isYearly = true }
            } label: {
                HStack(spacing: 4) {
                    Text("Yearly")
                    Text("Save 17%")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.green)
                        .foregroundStyle(.white)
                        .cornerRadius(4)
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isYearly ? Color.accentColor : Color.clear)
                .foregroundStyle(isYearly ? Color.white : Color.secondary)
            }
        }
        .buttonStyle(.plain)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Subscribe Button
    
    private var subscribeButton: some View {
        Button {
            purchaseSubscription()
        } label: {
            Text("Subscribe to \(selectedTier.displayName)")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .cornerRadius(12)
        }
        .disabled(subscriptionManager.isLoading)
    }
    
    // MARK: - Terms
    
    private var termsText: some View {
        Text("Subscriptions automatically renew unless canceled. Cancel anytime in Settings.")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    private func purchaseSubscription() {
        let product: Product?
        if isYearly {
            product = subscriptionManager.yearlyProduct(for: selectedTier)
        } else {
            product = subscriptionManager.monthlyProduct(for: selectedTier)
        }
        
        guard let product else {
            showingError = true
            return
        }
        
        purchaseTask?.cancel()
        purchaseTask = Task {
            do {
                _ = try await subscriptionManager.purchase(product)
            } catch {
                showingError = true
            }
        }
    }
}

// MARK: - Tier Card

private struct TierCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let isYearly: Bool
    let monthlyProduct: Product?
    let yearlyProduct: Product?
    let onSelect: () -> Void
    
    private var displayProduct: Product? {
        isYearly ? yearlyProduct : monthlyProduct
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tier.displayName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        if let product = displayProduct {
                            Text("\(product.displayPrice)\(isYearly ? "/year" : "/month")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        } else {
                            Text("Loading...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    } else {
                        Image(systemName: "circle")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(tier.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Text(feature)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SubscriptionView()
        .environment(SubscriptionManager())
}
