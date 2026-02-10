import SwiftUI
import Observation

@Observable
final class SearchState {
    var text: String = ""
    var isActive: Bool = false
    
    func toggle() {
        withAnimation(.spring(
            response: DesignConstants.Animation.morphResponse,
            dampingFraction: DesignConstants.Animation.morphDamping
        )) {
            isActive.toggle()
        }
    }
    
    func dismiss() {
        withAnimation(.spring(
            response: DesignConstants.Animation.morphResponse,
            dampingFraction: DesignConstants.Animation.morphDamping
        )) {
            isActive = false
            text = ""
        }
    }
    
    func clearText() {
        text = ""
    }
}
