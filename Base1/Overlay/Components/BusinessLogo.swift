//
//  BusinessLogo.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-09.
//

import SwiftUI

struct BusinessLogo: View {
    var isActive: Bool = false
    var action: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                
                Button(action: action) {
                    Image(systemName: "person.fill")
                        .font(.title3)
                        .foregroundStyle(isActive ? .white : .primary)
                        .frame(
                            width: DesignConstants.Settings.buttonSize,
                            height: DesignConstants.Settings.buttonSize
                        )
                        .background {
                            if isActive {
                                Circle().fill(.blue.gradient)
                            }
                        }
                }
                .glassEffect(.regular.interactive(), in: .circle)
                .padding(.leading, 20)
                Spacer()
            }
            Spacer()
        }
    }
}

