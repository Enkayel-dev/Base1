//
//  Business.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

@Model
public final class Business {

    // MARK: - Fields
    public var businessKey: String
    public var ownerAppleUserID: String  
    public var name: String
    public var ownerName: String
    public var email: String?
    public var phone: String?
    public var address: String?
    public var taxNumber: String?

    @Attribute(.externalStorage)
    public var logoData: Data?

    public var createdAt: Date

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \Client.business)
    public var clients: [Client] = []

    @Relationship(deleteRule: .cascade, inverse: \Project.business)
    public var projects: [Project] = []

    @Relationship(deleteRule: .cascade, inverse: \Resource.business)
    public var resources: [Resource] = []

    @Relationship(deleteRule: .cascade, inverse: \WorkflowTemplate.business)
    public var workflowTemplates: [WorkflowTemplate] = []

    @Relationship(deleteRule: .cascade, inverse: \Member.business)
    public var members: [Member] = []

    @Relationship(deleteRule: .cascade, inverse: \JobType.business)
    public var jobTypes: [JobType] = []

    @Relationship(deleteRule: .cascade, inverse: \ScopeItemTemplate.business)
    public var scopeItemTemplates: [ScopeItemTemplate] = []

    // MARK: - Init
    public init(
        businessKey: String,
        ownerAppleUserID: String,
        name: String,
        ownerName: String,
        email: String? = nil,
        phone: String? = nil,
        address: String? = nil
    ) {
        self.businessKey = businessKey
        self.ownerAppleUserID = ownerAppleUserID
        self.name = name
        self.ownerName = ownerName
        self.email = email
        self.phone = phone
        self.address = address
        self.createdAt = .now
    }
}
