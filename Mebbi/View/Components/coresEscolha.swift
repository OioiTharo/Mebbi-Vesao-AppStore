import SwiftUI

struct CoresEscolha: View {
    @EnvironmentObject var colorSelection: ColorSelection

    var body: some View {
        VStack {
            HStack {
                Text("Cor")
                    .foregroundColor(Color.azulPrincipal)
                    .font(.title3)
                    .padding(.horizontal, 30)
                Spacer()
                let corAtual = colorSelection.corSelecionada ?? colorSelection.coresRGB[0]
                let rgb = corAtual.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0.0 }
                let color = Color(red: rgb[0] / 255, green: rgb[1] / 255, blue: rgb[2] / 255)
                
                Circle()
                    .fill(color)
                    .frame(width: 30)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .overlay {
                        Circle()
                            .stroke(Color.cinza.opacity(0.5), lineWidth: 2)
                    }
            }
            .padding(.trailing, 17)
            .padding(.bottom, 30)

            ZStack {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 30), spacing: -1)], spacing: 0) {
                    ForEach(colorSelection.coresRGB, id: \.self) { cor in
                        let rgb = cor.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0.0 }
                        let color = Color(red: rgb[0] / 255, green: rgb[1] / 255, blue: rgb[2] / 255)
                        
                        Button(action: {
                            colorSelection.corSelecionada = cor
                        }) {
                            Rectangle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay {
                Rectangle()
                    .stroke(Color.cinza.opacity(0.2), lineWidth: 1)
            }
            .frame(height: 250)
            .padding(.horizontal)
            .padding(.bottom)
            
        }
    }
}

struct CoresEscolha_Previews: PreviewProvider {
    static var previews: some View {
        let colorSelection = ColorSelection()
        return CoresEscolha()
            .environmentObject(colorSelection)
    }
}
