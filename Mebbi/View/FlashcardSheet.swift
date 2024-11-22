import SwiftUI

struct FlashCardSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var flashCardManager: FlashCardManager
    let anotation: String
    let editingCard: FlashCard?
    @State private var editingCardCopy: FlashCard?
    @State private var questionText: String = ""
    @State private var answerText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Pergunta")
                        .foregroundColor(Color.azulPrincipal)
                        .font(.headline)
                        .padding(.trailing, 5)
                        .padding(.top,40)
                    Spacer()
                }
                TextField("Digite sua pergunta....", text: $questionText)
                    .foregroundColor(.wb)
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 200)
            
            Divider()
                .background(Color.azulPrincipal)
            
            VStack {
                HStack {
                    Text("Resposta")
                        .foregroundColor(Color.azulPrincipal)
                        .font(.headline)
                        .padding(.trailing, 5)
                    Spacer()
                }
                TextField("Digite sua resposta....", text: $answerText)
                    .foregroundColor(.wb)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .frame(height: 200)
            
            Button(action: {
                if let card = editingCardCopy {
                    flashCardManager.editFlashCard(card, newQuestion: questionText, newAnswer: answerText)
                } else {
                    flashCardManager.addFlashCard(question: questionText, answer: answerText, anotation: anotation)
                }
                dismiss()
            }) {
                Text(editingCardCopy != nil ? "Atualizar" : "Salvar")
                    .foregroundColor(Color.azulPrincipal)
            }
            .disabled(questionText.isEmpty || answerText.isEmpty)
            
            Spacer()
        }.appBackground()
        .padding(.top, 5)
        .onAppear {
            if let card = editingCard {
                if let updatedCard = flashCardManager.getFlashCard(by: card.id) {
                    editingCardCopy = updatedCard
                    questionText = updatedCard.question
                    answerText = updatedCard.answer
                }
            } else {
                questionText = ""
                answerText = ""
                editingCardCopy = nil
            }
        }
    }
}
