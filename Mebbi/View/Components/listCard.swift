import SwiftUI

struct ListCard: View {
    @ObservedObject var flashCardManager: FlashCardManager
    @Binding var editingCard: FlashCard?
    @Binding var isEditSheetPresented: Bool
    var anotation: String
    @State private var currentIndex = 0
    
    
    private var filteredCards: [FlashCard] {
        flashCardManager.getFlashCards(for: anotation)
    }
    
    func updateCurrentIndex(to newIndex: Int) {
        currentIndex = newIndex
    }
    
    var body: some View {
        if filteredCards.isEmpty {
            VStack {
                Spacer()
                Image("cardVazio")
                    .resizable()
                    .frame(width: 250, height: 200)
                Text("Crie flashcards clicando no botão +")
                    .foregroundColor(.textoVazio)
                    .font(.body)
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                Spacer()
                
            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        } else {
            VStack {
                HStack {
                    Text(anotation)
                        .foregroundColor(Color.azulPrincipal)
                        .padding(.top, 30)
                    Spacer()
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 20)
                
                TabView(selection: $currentIndex) {
                    ForEach(filteredCards) { card in
                        Cards(
                            flashCard: card,
                            flashCardManager: flashCardManager,
                            editingCard: $editingCard,
                            isEditSheetPresented: $isEditSheetPresented,
                            anotation: anotation,
                            currentIndex: $currentIndex
                        )
                        .frame(height: 400)
                        .tag(filteredCards.firstIndex(of: card)!)
                        .gesture(
                            DragGesture(minimumDistance: 50)
                                .onEnded { value in
                                    if value.translation.width < 0 {
                                        withAnimation {
                                            currentIndex = min(currentIndex + 1, filteredCards.count - 1)
                                            updateCurrentIndex(to: currentIndex)
                                        }
                                    } else if value.translation.width > 0 {
                                        withAnimation {
                                            currentIndex = max(currentIndex - 1, 0)
                                            updateCurrentIndex(to: currentIndex)
                                        }
                                    }
                                }
                        )
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 420)
                
                ProgressBar(
                    flashCardManager: flashCardManager,
                    currentIndex: $currentIndex,
                    totalCards: filteredCards.count
                )
                .padding()
                
                Text("Arraste o cartão para cima para editar ou excluir")
                    .font(.caption)
                    .foregroundColor(Color.azulPrincipal)
                    .padding(.top, 2)
            }
        }
    }
}
