//
//  SideDrawer.swift
//  Base1
//

import SwiftUI

// MARK: - Drawer Dismiss Environment Key

struct DrawerDismissAction {
    let action: () -> Void
    func callAsFunction() { action() }
}

private struct DrawerDismissKey: EnvironmentKey {
    static let defaultValue = DrawerDismissAction { }
}

extension EnvironmentValues {
    var dismissDrawer: DrawerDismissAction {
        get { self[DrawerDismissKey.self] }
        set { self[DrawerDismissKey.self] = newValue }
    }
}

// MARK: - SideDrawer View

struct SideDrawer<Content: View>: View {
    let onDismiss: () -> Void
    let content: Content

    init(onDismiss: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onDismiss = onDismiss
        self.content = content()
    }

    private var screenSize: CGSize {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first else {
            return .zero
        }
        return scene.screen.bounds.size
    }

    private var safeAreaInsets: UIEdgeInsets {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first,
              let window = scene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }

    var body: some View {
        let screenWidth = screenSize.width
        let drawerWidth = screenWidth - DesignConstants.Drawer.leadingPadding
        let topPadding = safeAreaInsets.top + DesignConstants.Drawer.topInset
        let bottomPadding = safeAreaInsets.bottom + DesignConstants.Drawer.bottomInset

        ZStack {
            // Clear tap target — no dimming, same visual plane as content
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(
                        response: DesignConstants.Animation.morphResponse,
                        dampingFraction: DesignConstants.Animation.morphDamping
                    )) {
                        onDismiss()
                    }
                }

            content
                .environment(\.dismissDrawer, DrawerDismissAction {
                    withAnimation(.spring(
                        response: DesignConstants.Animation.morphResponse,
                        dampingFraction: DesignConstants.Animation.morphDamping
                    )) {
                        onDismiss()
                    }
                })
                .scrollContentBackground(.hidden)
                .frame(width: drawerWidth)
                .frame(maxHeight: .infinity)
                .clipped()
                .background(.ultraThinMaterial)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: DesignConstants.Drawer.cornerRadius,
                    bottomLeadingRadius: DesignConstants.Drawer.cornerRadius,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0,
                    style: .continuous
                ))
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .transition(.move(edge: .trailing))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
