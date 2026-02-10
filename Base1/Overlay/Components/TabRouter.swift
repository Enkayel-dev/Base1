//
//  TabRouter.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI
import Observation

@Observable
final class TabRouter {
    var selectedTab: Int = 0
    
    func select(_ tab: Int) {
        withAnimation(.spring(response: DesignConstants.Animation.quickResponse)) {
            selectedTab = tab
        }
    }
    
    func offsetForTab(_ tab: Int, screenWidth: CGFloat) -> CGFloat {
        if selectedTab == tab { return 0 }
        else if selectedTab > tab { return -screenWidth }
        else { return screenWidth }
    }
}
