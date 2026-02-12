//
//  ProjectPhoto.swift
//  Base1
//
//  Created by Antigravity on 2026-02-12.
//

import SwiftUI
import SwiftData

@Model
public final class ProjectPhoto {

    // MARK: - Fields

    public var businessKey: String
    public var createdAt: Date
    public var caption: String?

    @Attribute(.externalStorage)
    public var imageData: Data?

    // MARK: - Relationships

    public var project: Project?

    // MARK: - Init

    public init(
        businessKey: String,
        imageData: Data? = nil,
        caption: String? = nil
    ) {
        self.businessKey = businessKey
        self.imageData = imageData
        self.caption = caption
        self.createdAt = .now
    }
}
