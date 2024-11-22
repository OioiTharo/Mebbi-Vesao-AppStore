import SwiftUI

struct TabBarCustom: View {
    @StateObject private var tabBarSettings = TabBarSettings()
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            TabView(selection: $tabBarSettings.selectedTab) {
                ContentView()
                    .tag(Tab.anotacoes)
                    .toolbar(.hidden, for: .tabBar)
                    .environmentObject(tabBarSettings)
                
                MeusFlashCardView()
                    .tag(Tab.flashcards)
                    .toolbar(.hidden, for: .tabBar)
                    .environmentObject(tabBarSettings)
                
                CategoriaView(path: $path)
                    .tag(Tab.categorias)
                    .toolbar(.hidden, for: .tabBar)
                    .environmentObject(tabBarSettings)
            }
            .overlay(alignment: .bottom) {
                if tabBarSettings.isVisible {
                    CustomTabBar(selectedTab: $tabBarSettings.selectedTab)
                }
            }
        }
        .environmentObject(tabBarSettings)
        
    }
}
