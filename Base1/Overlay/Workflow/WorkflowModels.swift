//
//  WorkflowModels.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

// MARK: - Workflow Instance

@Model
public final class Workflow {

    // MARK: - Fields

    public var title: String
    public var icon: String
    public var iconColorHex: String
    public var currentStepIndex: Int = 0
    public var isPaused: Bool = false
    public var isCompleted: Bool = false

    // MARK: - Relationships

    @Relationship(deleteRule: .cascade, inverse: \WorkflowStep.workflow)
    public var steps: [WorkflowStep] = []

    public var client: Client?
    public var project: Project?
    public var template: WorkflowTemplate?

    // MARK: - Computed

    public var isActive: Bool { !isPaused && !isCompleted }

    public var currentStepName: String {
        let sorted = sortedSteps
        guard sorted.indices.contains(currentStepIndex) else { return "" }
        return sorted[currentStepIndex].title
    }

    public var progress: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(currentStepIndex) / Double(steps.count)
    }

    public var sortedSteps: [WorkflowStep] {
        steps.sorted { $0.sortOrder < $1.sortOrder }
    }

    public enum Status: String, Codable {
        case active
        case paused
        case completed

        var tint: Color {
            switch self {
            case .active: return .blue
            case .paused: return .orange
            case .completed: return .green
            }
        }
    }

    public var status: Status {
        if isCompleted { return .completed }
        if isPaused { return .paused }
        return .active
    }

    public var iconColor: Color {
        Color(hex: iconColorHex) ?? .blue
    }

    // MARK: - Init

    public init(
        title: String,
        icon: String = "list.bullet",
        iconColor: Color = .blue
    ) {
        self.title = title
        self.icon = icon
        self.iconColorHex = iconColor.toHex() ?? "#0000FF"
        self.currentStepIndex = 0
        self.isPaused = false
        self.isCompleted = false
    }
}

// MARK: - Workflow Step Instance

@Model
public final class WorkflowStep {

    // MARK: - Fields

    public var title: String
    public var subtitle: String?
    public var viewKey: String
    public var requiresAction: Bool
    public var sortOrder: Int

    // MARK: - Relationships

    public var workflow: Workflow?

    // MARK: - Init

    public init(
        title: String,
        subtitle: String? = nil,
        viewKey: String,
        requiresAction: Bool = true,
        sortOrder: Int = 0
    ) {
        self.title = title
        self.subtitle = subtitle
        self.viewKey = viewKey
        self.requiresAction = requiresAction
        self.sortOrder = sortOrder
    }
}

// MARK: - Color Hex Helpers

extension Color {
    func toHex() -> String? {
        guard let components = cgColor?.components, components.count >= 3 else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }

    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
