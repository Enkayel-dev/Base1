//
//  WorkflowViewFactory.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI

struct WorkflowViewFactory {
    
    @ViewBuilder
    static func view(for key: String) -> some View {
        switch key {
        case "ClientInfoView":
            Text("Client Info View") // Replace with actual View
        case "ScheduleView":
            Text("Schedule View") // Replace with actual View
        case "ProjectView":
            Text("Project View") // Replace with actual View
        default:
            ContentUnavailableView("Unknown View", systemImage: "questionmark.circle")
        }
    }
}
