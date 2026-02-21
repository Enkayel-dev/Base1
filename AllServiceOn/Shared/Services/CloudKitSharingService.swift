//
//  CloudKitSharingService.swift
//  Base1
//
//  Manages CloudKit sharing for team collaboration.
//

import SwiftUI
import SwiftData
import CloudKit

/// Service for managing CloudKit-based team sharing
@MainActor @Observable
final class CloudKitSharingService {
    
    // MARK: - State
    
    private(set) var isSharing = false
    private(set) var error: Error?
    private(set) var pendingInvites: [PendingShareInvite] = []
    private(set) var isAvailable = false
    
    // MARK: - Dependencies (lazy initialization)
    
    private var _container: CKContainer?
    private var _database: CKDatabase?
    private let containerIdentifier: String
    
    private var container: CKContainer {
        if _container == nil {
            _container = CKContainer(identifier: containerIdentifier)
        }
        return _container!
    }
    
    private var database: CKDatabase {
        if _database == nil {
            _database = container.privateCloudDatabase
        }
        return _database!
    }
    
    // MARK: - Initialization
    
    init(containerIdentifier: String = "iCloud.com.base1.app") {
        self.containerIdentifier = containerIdentifier
        // Don't initialize CKContainer here - defer until actually needed
    }
    
    /// Check if CloudKit is available (has entitlements)
    func checkAvailability() async {
        do {
            // This will fail if entitlements are missing
            _ = try await CKContainer(identifier: containerIdentifier).accountStatus()
            isAvailable = true
        } catch {
            isAvailable = false
            self.error = CloudKitSharingError.notConfigured
        }
    }
    
    // MARK: - Public API
    
    /// Create a share for the business to invite team members
    func createBusinessShare(
        for business: Business,
        invitingMember member: Member
    ) async throws -> CKShare {
        guard isAvailable else {
            throw CloudKitSharingError.notConfigured
        }
        
        isSharing = true
        defer { isSharing = false }
        
        // Create a CKRecord for the business (or use existing if synced)
        let businessRecordID = CKRecord.ID(recordName: business.businessKey)
        let businessRecord = CKRecord(recordType: "Business", recordID: businessRecordID)
        businessRecord["name"] = business.name
        businessRecord["ownerAppleUserID"] = business.ownerAppleUserID
        
        // Create the share
        let share = CKShare(rootRecord: businessRecord)
        share[CKShare.SystemFieldKey.title] = "Join \(business.name)"
        share.publicPermission = .none // Private sharing only
        
        // Save both records
        let operation = CKModifyRecordsOperation(recordsToSave: [businessRecord, share])
        operation.savePolicy = .changedKeys
        
        return try await withCheckedThrowingContinuation { continuation in
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    // Store pending invite
                    let invite = PendingShareInvite(
                        memberEmail: member.email,
                        memberDisplayName: member.displayName,
                        shareURL: share.url,
                        createdAt: .now
                    )
                    Task { @MainActor in
                        self.pendingInvites.append(invite)
                    }
                    continuation.resume(returning: share)
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            database.add(operation)
        }
    }
    
    /// Add a participant to an existing share
    func addParticipant(
        email: String,
        to share: CKShare,
        permission: CKShare.ParticipantPermission = .readWrite
    ) async throws {
        guard isAvailable else {
            throw CloudKitSharingError.notConfigured
        }
        
        isSharing = true
        defer { isSharing = false }
        
        // Look up the user by email using async API
        let participant = try await container.shareParticipant(forEmailAddress: email)
        
        participant.permission = permission
        share.addParticipant(participant)
        
        // Save the updated share
        try await database.save(share)
    }
    
    /// Generate a share URL for invitation
    func generateShareURL(for share: CKShare) -> URL? {
        share.url
    }
    
    /// Accept a share invitation (called when user taps share link)
    func acceptShareInvitation(
        metadata: CKShare.Metadata,
        modelContext: ModelContext,
        authService: AuthService
    ) async throws {
        guard isAvailable else {
            throw CloudKitSharingError.notConfigured
        }
        
        isSharing = true
        defer { isSharing = false }
        
        // Accept the share
        try await container.accept(metadata)
        
        // Get current user info
        guard let userID = authService.authState.userID else {
            throw CloudKitSharingError.notAuthenticated
        }
        
        // The shared zone is now accessible
        // Find or create member record and link to this user
        if let businessKey = metadata.rootRecord?.recordID.recordName {
            // Look for pending member invite with this user's email
            let userEmail = authService.credentials?.email
            
            if let email = userEmail {
                let descriptor = FetchDescriptor<Member>(
                    predicate: #Predicate { member in
                        member.businessKey == businessKey &&
                        member.email == email &&
                        member.inviteStatusRaw == "pending"
                    }
                )
                
                if let member = try? modelContext.fetch(descriptor).first {
                    // Link the member to this Apple User ID
                    member.appleUserID = userID
                    member.cloudKitShareParticipantID = metadata.participantID?.recordName
                    member.inviteStatus = .accepted
                    member.acceptedAt = .now
                    member.updatedAt = .now
                    
                    try modelContext.save()
                }
            }
        }
    }
    
    /// Remove a participant from the share
    func removeParticipant(
        member: Member,
        from share: CKShare
    ) async throws {
        guard isAvailable else {
            throw CloudKitSharingError.notConfigured
        }
        
        guard let participantID = member.cloudKitShareParticipantID else {
            throw CloudKitSharingError.participantNotFound
        }
        
        // Find and remove the participant
        if let participant = share.participants.first(where: { 
            $0.userIdentity.userRecordID?.recordName == participantID 
        }) {
            share.removeParticipant(participant)
            try await database.save(share)
        }
    }
    
    /// Check current user's share participant status
    func checkParticipantStatus() async throws -> ParticipantStatus {
        guard isAvailable else {
            throw CloudKitSharingError.notConfigured
        }
        
        do {
            let userID = try await container.userRecordID()
            
            // Check if user is owner or participant in any shares
            let zones = try await database.allRecordZones()
            
            for zone in zones {
                if zone.zoneID.ownerName == userID.recordName {
                    return .owner
                }
            }
            
            // Check shared zones
            let sharedDB = container.sharedCloudDatabase
            let sharedZones = try await sharedDB.allRecordZones()
            
            if !sharedZones.isEmpty {
                return .participant
            }
            
            return .none
            
        } catch {
            throw error
        }
    }
    
    /// Fetch all pending share invites
    func fetchPendingInvites(for businessKey: String, context: ModelContext) -> [Member] {
        let descriptor = FetchDescriptor<Member>(
            predicate: #Predicate { member in
                member.businessKey == businessKey &&
                member.inviteStatusRaw == "pending"
            }
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
}

// MARK: - Supporting Types

/// Pending share invitation
struct PendingShareInvite: Identifiable {
    let id = UUID()
    let memberEmail: String
    let memberDisplayName: String
    let shareURL: URL?
    let createdAt: Date
}

/// Participant status in CloudKit sharing
enum ParticipantStatus {
    case owner
    case participant
    case none
}

/// CloudKit sharing errors
enum CloudKitSharingError: LocalizedError {
    case notAuthenticated
    case participantNotFound
    case shareNotFound
    case permissionDenied
    case networkError
    case notConfigured
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to share with team members"
        case .participantNotFound:
            return "Could not find the invited user"
        case .shareNotFound:
            return "Share not found"
        case .permissionDenied:
            return "You don't have permission to modify this share"
        case .networkError:
            return "Network error. Please try again."
        case .notConfigured:
            return "CloudKit is not configured. Team sharing requires an active Apple Developer account."
        }
    }
}

// MARK: - CKShare.Metadata Extension

extension CKShare.Metadata {
    var participantID: CKRecord.ID? {
        // Extract participant ID from metadata
        // This would be set when the share is accepted
        nil
    }
}
