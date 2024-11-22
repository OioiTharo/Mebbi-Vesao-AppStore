import SwiftUI

struct ItemLista: View {
    var titulo: String
    var cor: Color
    var revisao: Bool
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    if revisao {
                        Text("Revisão")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .padding(.top, 0)
                    }
                    
                    Text(titulo)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.leading)
                Spacer()
                Rectangle()
                    .fill(cor)
                    .frame(width: 50)
                    .overlay(
                        Rectangle()
                            .frame(width: 3)
                            .foregroundColor(Color.background),
                        alignment: .leading
                    )
            }
            .frame(height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .background(revisao ? Color.amareloPrincipal : Color.azulPrincipal)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .disabled(revisao)
    }
}

#Preview {
    ItemLista(titulo: "Matemática e cieidjjsjadad", cor: Color.blue, revisao: true)
}
