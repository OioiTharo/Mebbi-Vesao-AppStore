import SwiftUI

struct FlashCardView: View {
    @State private var isEditSheetPresented = false
    @StateObject private var flashCardManager = FlashCardManager.shared
    @State private var editingCard: FlashCard?
    var anotation: String
    @EnvironmentObject var tabBarSettings: TabBarSettings
    @Environment(\.presentationMode) var presentationMode

    private func botaoVoltar() -> some View {
        Image(systemName: "chevron.left")
            .foregroundColor(Color.azulPrincipal)
            .font(.title2)
    }

    var body: some View {
        NavigationStack {
            VStack {
                ListCard(
                    flashCardManager: flashCardManager,
                    editingCard: $editingCard,
                    isEditSheetPresented: $isEditSheetPresented,
                    anotation: anotation
                )
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        botaoVoltar()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("FlashCards")
                        .foregroundColor(Color.azulPrincipal)
                        .font(.title2)
                        .fontWeight(.bold)
                       
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        editingCard = nil
                        isEditSheetPresented = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color.azulPrincipal)
                            .font(.title3)
                           
                    }
                }
            }
           
            .sheet(isPresented: $isEditSheetPresented) {
                FlashCardSheet(
                    flashCardManager: flashCardManager,
                    anotation: anotation,
                    editingCard: editingCard
                )
            }
        }
        .appBackground()
        .onAppear {
            withAnimation {
                tabBarSettings.hide()
            }
        }
        .onDisappear {
            withAnimation {
                tabBarSettings.restorePreviousState()
            }
        }
    }
}

#Preview {
    FlashCardView(anotation: "Quimica quantica")
}
