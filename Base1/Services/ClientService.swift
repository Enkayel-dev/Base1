//
//  Untitled.swift
//  Base1
//
//  Created by Nicholas Lachapelle on 2026-02-10.
//

import SwiftUI
import SwiftData

@Observable
final class ClientService {

    func clients(
        from allClients: [Client],
        filter: FilterOption
    ) -> [Client] {
        switch filter {
        case .all:
            return allClients
        case .lead:
            return allClients.filter { $0.status == .lead }
        case .active:
            return allClients.filter { $0.status == .active }
        case .closed:
            return allClients.filter { $0.status == .closed }
        }
    }
}
