import SwiftUI

struct categoriaFlashcards: View {
    var titulo: String
    var corInferior: Color
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 0) {
                Text(titulo)
                    .foregroundColor(.white)
                    .padding(.top, 30)
                    .font(.headline)
                    .padding(.horizontal)
                Spacer()
                Rectangle()
                    .fill(corInferior)
                    .frame(height:30)
                    .overlay(
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(Color.background),
                        alignment:.top
                    )
            }
            .frame(height:90)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .background(Color.azulPrincipal)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        
    }
}

#Preview {
    categoriaFlashcards(titulo: "Química", corInferior: Color.green)
}
