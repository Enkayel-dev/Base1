//
//  WorkflowModels.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

@Model
public final class Workflow {
    public var id: String
    public var title: String
    public var icon: String
    public var iconColorHex: String // Storing color as hex since Color isn't directly persistable
    
    @Relationship(deleteRule: .cascade, inverse: \WorkflowStep.workflow)
    public var steps: [WorkflowStep] = []
    
    public var currentStepIndex: Int = 0
    public var isPaused: Bool = false
    public var isCompleted: Bool = false
    // Added based on usage in WorkflowMiniCard
    public var isActive: Bool { !isPaused && !isCompleted } 
    
    public var currentStepName: String {
        guard steps.indices.contains(currentStepIndex) else { return "" }
        return steps[currentStepIndex].title
    }
    
    public var progress: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(currentStepIndex) / Double(steps.count)
    }
    
    // Status enum needs to be Codable for SwiftData or just computed
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

    public init(id: String, title: String, icon: String = "list.bullet", iconColor: Color = .blue, steps: [WorkflowStep] = []) {
        self.id = id
        self.title = title
        self.icon = icon
        self.iconColorHex = iconColor.toHex() ?? "#0000FF"
        self.steps = steps
        self.currentStepIndex = 0
        self.isPaused = false
        self.isCompleted = false
    }
}

@Model
public final class WorkflowStep {
    public var id: String
    public var title: String
    public var subtitle: String?
    public var viewKey: String // Replaces AnyView
    public var requiresAction: Bool
    
    public var workflow: Workflow?
    
    public init(id: String, title: String, subtitle: String? = nil, viewKey: String, requiresAction: Bool = true) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.viewKey = viewKey
        self.requiresAction = requiresAction
    }
}

// Helper extension for Color hex conversion (basic implementation)
extension Color {
    func toHex() -> String? {
        // Implementation for converting Color to Hex String
        // For simplicity, we can use a standard implementation or rely on a helper if available in project.
        // Assuming a basic implementation for now.
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
