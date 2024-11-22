import AVFoundation
import SwiftUI

struct Cards: View {
    @State private var isFlipped: Bool = true
    @State private var isEditing: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    let flashCard: FlashCard
    @ObservedObject var flashCardManager: FlashCardManager
    @Binding var editingCard: FlashCard?
    @Binding var isEditSheetPresented: Bool
    let anotation: String
    @Binding var currentIndex: Int
    
    private var currentCard: FlashCard {
        if let updatedCard = flashCardManager.getFlashCard(by: flashCard.id) {
            return updatedCard
        }
        return flashCard
    }
    
    func playFlipSound() {
        if let soundURL = Bundle.main.url(forResource: "flipSound", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Erro ao tentar reproduzir o som: \(error.localizedDescription)")
            }
        }
    }
    
    func vibrate() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    var body: some View {
        ZStack {
            if isFlipped {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.azulPrincipal)
                    .frame(width: 300, height: 400)
                    .shadow(color: .black, radius: 5)
                    .overlay(
                        VStack {
                            Text("Pergunta")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.top, 30)
                                .padding(.trailing, 180)
                            Spacer()
                            Text(currentCard.question)
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.horizontal,10)
                            Spacer()
                            Text("Toque no cartão para ver a resposta")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.bottom, 30)
                        }
                    )
                    .gesture(
                        DragGesture(minimumDistance: 50)
                            .onEnded { value in
                                if value.translation.height < 0 {
                                    withAnimation {
                                        isEditing.toggle()
                                        editingCard = currentCard
                                    }
                                } else if value.translation.height > 0 {
                                    withAnimation {
                                        isEditing = false
                                    }
                                }
                            }
                    )
                
                if isEditing {
                    EditCard(
                        flashCardManager: flashCardManager,
                        flashCard: currentCard,
                        isEditSheetPresented: $isEditSheetPresented,
                        editingCard: $editingCard
                    )
                    .padding(.top, 320)
                }
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.azulPrincipal.opacity(0.6))
                    .frame(width: 300, height: 400)
                    .shadow(color: .black, radius: 2)
                    .overlay(
                        VStack {
                            Text("Resposta")
                                .scaleEffect(x: -1, y: 1)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.top, 30)
                                .padding(.leading, 180)
                            Spacer()
                            Text(currentCard.answer)
                                .scaleEffect(x: -1, y: 1)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal,5)
                            Spacer()
                            Text("Toque no cartão para ver a pergunta")
                                .scaleEffect(x: -1, y: 1)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.bottom, 30)
                        }
                    )
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 0 : 180),
            axis: (x: 0, y: -1, z: 0)
        )
        .onTapGesture {
            withAnimation {
                playFlipSound()
                isFlipped.toggle()
                vibrate()
            }
        }
        .id(currentCard.id)
    }
}
