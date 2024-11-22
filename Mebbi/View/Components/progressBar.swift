import SwiftUI

struct ProgressBar: View {
    @ObservedObject var flashCardManager: FlashCardManager
    @Binding var currentIndex: Int
    let totalCards: Int
    
    var progress: Double {
        guard totalCards > 0 else { return 0.0 }
        return Double(currentIndex + 1) / Double(totalCards)
    }
    
    var body: some View {
        VStack {
            Text("Card \(currentIndex + 1) / \(totalCards)")
                .font(.subheadline)
                .foregroundColor(Color.azulPrincipal)
            
            HStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 300, height: 20)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.azulPrincipal)
                        .frame(width: CGFloat(progress) * 300, height: 20)
                }
            }
        }
    }
}
