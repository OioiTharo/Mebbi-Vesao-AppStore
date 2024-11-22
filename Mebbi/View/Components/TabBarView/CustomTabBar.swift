import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Color.background
                
                HStack {
                    TabButton(
                        imageName: selectedTab == .anotacoes ? "doc.text.fill" : "doc.text",
                        text: "Anotações",
                        isSelected: selectedTab == .anotacoes
                    ) {
                        selectedTab = .anotacoes
                    }
                    .padding(.trailing, 25)
                    
                    TabButton(
                        imageName: selectedTab == .flashcards ? "flash.fill" : "flash",
                        text: "Flashcards",
                        isSelected: selectedTab == .flashcards,
                        isSystemImage: false
                    ) {
                        selectedTab = .flashcards
                    }
                    .padding(.horizontal)
                    
                    TabButton(
                        imageName: selectedTab == .categorias ? "tray.fill" : "tray",
                        text: "Categorias",
                        isSelected: selectedTab == .categorias
                    ) {
                        selectedTab = .categorias
                    }
                    .padding(.leading, 25)
                    .padding(.top,8)
                }
                .padding(.bottom, 10)
            }
            .frame(height: 80)
            .background(Color.clear)
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
