//
//  TabRouter.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI
import Observation

@MainActor @Observable
final class TabRouter {
    var selectedTab: Int = 0
    var isSettingsActive: Bool = false
    var isBusinessProfileActive: Bool = false
    
    func select(_ tab: Int) {
        withAnimation(.spring(response: DesignConstants.Animation.quickResponse)) {
            selectedTab = tab
            isSettingsActive = false
            isBusinessProfileActive = false
        }
    }
    
    func offsetForTab(_ tab: Int, screenWidth: CGFloat) -> CGFloat {
        if isSettingsActive {
            return -screenWidth // Slide out to left
        }
        if isBusinessProfileActive {
            return screenWidth // Slide out to right
        }
        if selectedTab == tab { return 0 }
        else if selectedTab > tab { return -screenWidth }
        else { return screenWidth }
    }
    
    func settingsOffset(screenWidth: CGFloat) -> CGFloat {
        if isSettingsActive { return 0 }
        else { return screenWidth } // Hidden to right
    }
    
    func businessProfileOffset(screenWidth: CGFloat) -> CGFloat {
        if isBusinessProfileActive { return 0 }
        else { return -screenWidth } // Hidden to left
    }
}
