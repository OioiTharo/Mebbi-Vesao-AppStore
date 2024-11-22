import SwiftUI

struct EditCard: View {
    @ObservedObject var flashCardManager: FlashCardManager
    var flashCard: FlashCard
    @Binding var isEditSheetPresented: Bool
    @Binding var editingCard: FlashCard?
    
    var body: some View {
        Rectangle()
            .fill(Color.azulPrincipal)
            .frame(width: 300, height: 50)
            .overlay(
                HStack {
                    Button(action: {
                        editingCard = flashCard
                        isEditSheetPresented = true
                    }) {
                        VStack {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("Editar")
                                .foregroundColor(.white)
                                .font(.caption)
                        }.padding(.leading, 50)
                    }
                    Spacer()
                    Button(action: {
                        flashCardManager.deleteFlashCard(flashCard)
                        flashCardManager.saveFlashCards()
                    }) {
                        VStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.headline)
                            Text("Excluir")
                                .foregroundColor(.red)
                                .font(.caption)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        }.padding(.trailing, 50)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

