//
//  AuthService.swift
//  Base1
//
//  Handles Sign in with Apple authentication and session management.
//

import SwiftUI
import AuthenticationServices
import Security

/// Authentication state for the app
enum AuthState: Equatable {
    case unknown
    case signedOut
    case signedIn(userID: String)
    
    var isSignedIn: Bool {
        if case .signedIn = self { return true }
        return false
    }
    
    var userID: String? {
        if case .signedIn(let id) = self { return id }
        return nil
    }
}

/// Persisted user credentials from Sign in with Apple
struct AppleUserCredentials: Codable {
    let userID: String
    let email: String?
    let fullName: PersonNameComponents?
    let identityToken: Data?
    
    var displayName: String {
        if let name = fullName {
            return PersonNameComponentsFormatter.localizedString(from: name, style: .default)
        }
        return email ?? "User"
    }
}

/// Service for managing Sign in with Apple authentication
@MainActor @Observable
final class AuthService {
    
    // MARK: - State
    
    private(set) var authState: AuthState = .unknown
    private(set) var credentials: AppleUserCredentials?
    private(set) var isLoading = false
    private(set) var error: Error?
    
    // MARK: - Keychain Keys
    
    private let keychainUserIDKey = "com.base1.appleUserID"
    private let keychainCredentialsKey = "com.base1.appleCredentials"
    
    // MARK: - Initialization
    
    init() {
        // Check existing session on init
        Task {
            await checkExistingSession()
        }
    }
    
    // MARK: - Public API
    
    /// Check if user has an existing valid session
    func checkExistingSession() async {
        isLoading = true
        defer { isLoading = false }
        
        // Try to load stored user ID from keychain
        guard let storedUserID = loadUserIDFromKeychain() else {
            authState = .signedOut
            return
        }
        
        // Verify the credential is still valid with Apple
        let provider = ASAuthorizationAppleIDProvider()
        
        do {
            let state = try await provider.credentialState(forUserID: storedUserID)
            
            switch state {
            case .authorized:
                // Load full credentials if available
                credentials = loadCredentialsFromKeychain()
                authState = .signedIn(userID: storedUserID)
                
            case .revoked, .notFound:
                // Clear stored credentials and sign out
                clearKeychain()
                authState = .signedOut
                
            case .transferred:
                // Account was transferred to a different team
                // Treat as signed out and require re-auth
                clearKeychain()
                authState = .signedOut
                
            @unknown default:
                authState = .signedOut
            }
        } catch {
            self.error = error
            // On error, assume signed out for security
            authState = .signedOut
        }
    }
    
    /// Handle successful authorization from Sign in with Apple
    func handleAuthorization(_ authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            error = AuthError.invalidCredential
            return
        }
        
        let userID = appleIDCredential.user
        
        // Create credentials object
        let creds = AppleUserCredentials(
            userID: userID,
            email: appleIDCredential.email,
            fullName: appleIDCredential.fullName,
            identityToken: appleIDCredential.identityToken
        )
        
        // Save to keychain
        saveUserIDToKeychain(userID)
        saveCredentialsToKeychain(creds)
        
        // Update state
        credentials = creds
        authState = .signedIn(userID: userID)
        error = nil
    }
    
    /// Handle authorization error
    func handleAuthorizationError(_ authError: Error) {
        if let asError = authError as? ASAuthorizationError {
            switch asError.code {
            case .canceled:
                // User canceled, don't treat as error
                return
            case .failed,
                 .invalidResponse,
                 .notHandled,
                 .notInteractive,
                 .unknown,
                 .credentialImport,
                 .credentialExport,
                 .matchedExcludedCredential,
                 .deviceNotConfiguredForPasskeyCreation,
                 .preferSignInWithApple:
                self.error = authError
            @unknown default:
                self.error = authError
            }
        } else {
            self.error = authError
        }
    }
    
    /// Sign out the current user
    func signOut() {
        clearKeychain()
        credentials = nil
        authState = .signedOut
        error = nil
    }
    
    #if DEBUG
    /// Sign in as a test user for development (bypasses Sign in with Apple)
    func signInAsTestUser() {
        let testUserID = "test-user-\(UUID().uuidString.prefix(8))"
        
        let testCredentials = AppleUserCredentials(
            userID: testUserID,
            email: "testuser@example.com",
            fullName: PersonNameComponents(givenName: "Test", familyName: "User"),
            identityToken: nil
        )
        
        // Save to keychain so session persists
        saveUserIDToKeychain(testUserID)
        saveCredentialsToKeychain(testCredentials)
        
        credentials = testCredentials
        authState = .signedIn(userID: testUserID)
        error = nil
    }
    #endif
    
    // MARK: - Keychain Operations
    
    private func saveUserIDToKeychain(_ userID: String) {
        guard let data = userID.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainUserIDKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func loadUserIDFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainUserIDKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let userID = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return userID
    }
    
    private func saveCredentialsToKeychain(_ creds: AppleUserCredentials) {
        guard let data = try? JSONEncoder().encode(creds) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainCredentialsKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func loadCredentialsFromKeychain() -> AppleUserCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainCredentialsKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let creds = try? JSONDecoder().decode(AppleUserCredentials.self, from: data) else {
            return nil
        }
        
        return creds
    }
    
    private func clearKeychain() {
        let userIDQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainUserIDKey
        ]
        SecItemDelete(userIDQuery as CFDictionary)
        
        let credsQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainCredentialsKey
        ]
        SecItemDelete(credsQuery as CFDictionary)
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidCredential
    case keychainError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid authentication credential"
        case .keychainError:
            return "Failed to access secure storage"
        case .networkError:
            return "Network error during authentication"
        }
    }
}
