//
//  DesignConstants.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

enum DesignConstants {
    // MARK: - Bottom Bar
    enum BottomBar {
        static let cornerRadius: CGFloat = 48
        static let horizontalPadding: CGFloat = 8
        static let bottomPadding: CGFloat = 8
        static let innerHorizontalPadding: CGFloat = 12
        static let innerVerticalPadding: CGFloat = 12
    }
    
    // MARK: - Tab Bar
    enum TabBar {
        static let itemHeight: CGFloat = 36
        static let activePaddingH: CGFloat = 16
        static let inactivePaddingH: CGFloat = 12
        static let spacing: CGFloat = 8
    }
    
    // MARK: - Workflow Card
    enum WorkflowCard {
        static let iconSize: CGFloat = 48
        static let iconCornerRadius: CGFloat = 12
        static let progressHeight: CGFloat = 3
        static let handleSize: CGFloat = 16
        static let trackHeight: CGFloat = 20
    }
    
    // MARK: - Settings
    enum Settings {
        static let buttonSize: CGFloat = 44
    }
    
    // MARK: - Animation
    enum Animation {
        static let tabSwitchResponse: Double = 0.35
        static let tabSwitchDamping: Double = 0.85
        static let quickResponse: Double = 0.3
        static let morphResponse: Double = 0.4
        static let morphDamping: Double = 0.8
    }
}
