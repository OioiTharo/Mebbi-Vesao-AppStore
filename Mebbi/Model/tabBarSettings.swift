import Foundation
import SwiftUI

class TabBarSettings: ObservableObject {
    @Published var isVisible = true {
        didSet {
            if shouldTrackChanges {
                visibilityStack.append(oldValue)
            }
        }
    }
    @Published var selectedTab: Tab = .anotacoes
    private var visibilityStack: [Bool] = []
    private var shouldTrackChanges = true
    private var navigationPath: Binding<NavigationPath>?
    
    func setNavigationPath(_ path: Binding<NavigationPath>) {
        self.navigationPath = path
    }
    
    func hide() {
        shouldTrackChanges = true
        isVisible = false
    }
    
    func show() {
        shouldTrackChanges = true
        isVisible = true
    }
    
    func forceShow() {
        shouldTrackChanges = false
        isVisible = true
        visibilityStack.removeAll()
    }
    
    func forceHide() {
        shouldTrackChanges = false
        isVisible = false
        visibilityStack.removeAll()
    }
    
    func restorePreviousState() {
        guard !visibilityStack.isEmpty else { return }
        shouldTrackChanges = false
        isVisible = visibilityStack.removeLast()
    }
    
    func navigateToRoot() {
        selectedTab = .anotacoes
        if let path = navigationPath {
            path.wrappedValue = NavigationPath()
        }
    }
}



enum Tab: String {
    case anotacoes = "anotacao"
    case flashcards = "flashs"
    case categorias = "cate"
}
