import SwiftUI

struct FlashCardSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var flashCardManager: FlashCardManager
    let anotation: String
    let editingCard: FlashCard?
    @State private var editingCardCopy: FlashCard?
    @State private var questionText: String = ""
    @State private var answerText: String = ""
    let maxCaracteres: Int = 32
    
    func limitCharactersPerLine(_ input: String) -> String {
            let lines = input.split(separator: "\n", omittingEmptySubsequences: false)
            let limitedLines = lines.map { line in
                line.prefix(maxCaracteres)
            }
            return limitedLines.joined(separator: "\n")
        }

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
                ZStack(alignment: .top){
                    TextEditor(text: $questionText)
                        .foregroundColor(.wb)
                    if questionText.isEmpty {
                        HStack{
                            Text("Digite sua pergunta....")
                                .foregroundColor(.wb.opacity(0.3))
                                .padding(.top, 8)
                                .padding(.leading, 2)
                            Spacer()
                        }
                    }
                }
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
                ZStack(alignment: .top){
                    TextEditor(text: $answerText)
                        .foregroundColor(.wb)
                        .onChange(of: answerText){ newValue in
                            answerText = limitCharactersPerLine(newValue)
                        }
                    if answerText.count == maxCaracteres{
                        HStack{
                            Text("Limite de caracteres por linha atingido")
                                .foregroundColor(.red)
                                .font(.caption2)
                                .padding(.top,25)
                                .padding(.leading, 6)
                            Spacer()
                        }
                    }
                    if answerText.isEmpty {
                        HStack{
                            Text("Digite sua resposta....")
                                .foregroundColor(.wb.opacity(0.3))
                                .padding(.top, 8)
                                .padding(.leading, 2)
                            Spacer()
                        }
                    }
                }
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
