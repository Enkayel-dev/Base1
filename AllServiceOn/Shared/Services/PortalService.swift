//
//  PortalService.swift
//  Base1
//
//  Created by Claude on 2026-02-19.
//

import SwiftUI
import SwiftData
import Security

/// Service for generating secure magic links for client portal access
/// and estimate sharing.
@MainActor @Observable
final class PortalService {
    
    /// Base URL for the client portal (to be configured for production)
    private let baseURL = "https://portal.base1app.com"
    
    // MARK: - Estimate Sharing
    
    /// Generates a shareable link for a project estimate.
    /// - Parameter project: The project to share
    /// - Returns: The shareable URL, or nil if generation fails
    func generateEstimateLink(for project: Project) -> URL? {
        let token = generateSecureToken()
        project.estimateShareToken = token
        project.estimateSharedAt = .now
        
        return URL(string: "\(baseURL)/estimate/\(token)")
    }
    
    /// Checks if an estimate link has been generated for a project.
    func hasEstimateLink(for project: Project) -> Bool {
        project.estimateShareToken != nil
    }
    
    /// Gets the existing estimate link for a project, or nil if not shared.
    func getEstimateLink(for project: Project) -> URL? {
        guard let token = project.estimateShareToken else { return nil }
        return URL(string: "\(baseURL)/estimate/\(token)")
    }
    
    /// Revokes the estimate link for a project.
    func revokeEstimateLink(for project: Project) {
        project.estimateShareToken = nil
        project.estimateSharedAt = nil
    }
    
    // MARK: - Client Portal
    
    /// Generates a portal access link for a client.
    /// - Parameter client: The client to grant portal access
    /// - Returns: The portal URL, or nil if generation fails
    func generateClientPortalLink(for client: Client) -> URL? {
        // Generate new token if needed
        if client.portalToken == nil {
            client.portalToken = generateSecureToken()
            client.portalTokenCreatedAt = .now
        }
        
        client.portalEnabled = true
        
        guard let token = client.portalToken else { return nil }
        return URL(string: "\(baseURL)/client/\(token)")
    }
    
    /// Checks if portal access is enabled for a client.
    func hasPortalAccess(for client: Client) -> Bool {
        client.portalEnabled && client.portalToken != nil
    }
    
    /// Gets the existing portal link for a client, or nil if not enabled.
    func getPortalLink(for client: Client) -> URL? {
        guard client.portalEnabled, let token = client.portalToken else { return nil }
        return URL(string: "\(baseURL)/client/\(token)")
    }
    
    /// Disables portal access for a client without removing the token.
    func disablePortalAccess(for client: Client) {
        client.portalEnabled = false
    }
    
    /// Revokes portal access completely and removes the token.
    func revokePortalAccess(for client: Client) {
        client.portalToken = nil
        client.portalTokenCreatedAt = nil
        client.portalEnabled = false
    }
    
    /// Regenerates the portal token for a client (invalidates old link).
    func regeneratePortalToken(for client: Client) -> URL? {
        client.portalToken = generateSecureToken()
        client.portalTokenCreatedAt = .now
        client.portalEnabled = true
        
        guard let token = client.portalToken else { return nil }
        return URL(string: "\(baseURL)/client/\(token)")
    }
    
    // MARK: - Token Generation
    
    /// Generates a cryptographically secure URL-safe token.
    private func generateSecureToken() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        
        // Convert to URL-safe base64
        return Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
