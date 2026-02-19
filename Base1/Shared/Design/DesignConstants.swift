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
        static let activePaddingH: CGFloat = 12  // Reduced from 16
        static let inactivePaddingH: CGFloat = 8  // Reduced from 12
        static let spacing: CGFloat = 4  // Reduced from 8
    }
    
    // MARK: - Card
    enum Card {
        static let cornerRadius: CGFloat = 12
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
    
    // MARK: - BusinessLogo
    enum BusinessLogo {
        static let buttonSize: CGFloat = 44
    }
    
    // MARK: - Drawer
    enum Drawer {
        static let leadingPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 16
        /// Distance from safe area top to drawer top (clears BusinessLogo / SettingsButton)
        static let topInset: CGFloat = Settings.buttonSize + 8
        /// Distance from safe area bottom to drawer bottom (clears BottomBarView)
        static let bottomInset: CGFloat = 190
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
