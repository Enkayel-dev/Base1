//
//  SettingsButton.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct SettingsButton: View {
    var action: () -> Void = {}
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .frame(
                            width: DesignConstants.Settings.buttonSize,
                            height: DesignConstants.Settings.buttonSize
                        )
                }
                .glassEffect(.regular.interactive(), in: .circle)
                .padding(.trailing, 20)
            }
            Spacer()
        }
    }
}
