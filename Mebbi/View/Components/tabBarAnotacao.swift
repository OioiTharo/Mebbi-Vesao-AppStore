import SwiftUI

struct tabBarAnotacao: View {
    @Binding var desenhando: Bool
    @Binding var editandoDesenho: Bool
    @Binding var mostrandoActionSheet: Bool
    @Binding var mostrandoOpcoesCamera: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                mostrandoActionSheet = true
            }) {
                VStack {
                    Image(systemName: "paperclip")
                        .foregroundColor(Color.azulPrincipal)
                    Text("Anexar")
                        .foregroundColor(Color.azulPrincipal)
                        .font(.system(size: 12))
                }
            }
            .actionSheet(isPresented: $mostrandoActionSheet) {
                ActionSheet(title: Text("Anexar documentos"), message: Text("Você aceita anexar documentos do seus arquivos?"), buttons: [
                    .default(Text("Anexar Arquivo")) {
                        
                    },
                    .cancel()
                ])
            }
            
            Spacer()
            Button(action: {
                if desenhando {
                    editandoDesenho.toggle()
                } else {
                    desenhando = true
                    editandoDesenho = true
                }
            }) {
                VStack {
                    Image(systemName: "pencil.tip.crop.circle")
                        .foregroundColor(Color.azulPrincipal)
                    Text(editandoDesenho ? "OK" : "Desenhar")
                        .foregroundColor(Color.azulPrincipal)
                        .font(.system(size: 12))
                }
            }
            Spacer()
            Button(action: {
                mostrandoOpcoesCamera = true
            }) {
                VStack {
                    Image(systemName: "camera")
                        .foregroundColor(Color.azulPrincipal)
                    Text("Câmera")
                        .foregroundColor(Color.azulPrincipal)
                        .font(.system(size: 12))
                }
            }
            .actionSheet(isPresented: $mostrandoOpcoesCamera) {
                ActionSheet(title: Text("Fotos"), message: Text("O que você deseja?"), buttons: [
                    .default(Text("Tirar Foto")) {
                        // Adicionar a função para tirar foto
                    },
                    .default(Text("Escolher da Galeria")) {
                        // Adicionar a função para escolher foto da galeria
                    },
                    .cancel()
                ])
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

#Preview {
    @State var desenhando = false
    @State var editandoDesenho = false
    @State var mostrandoActionSheet = false
    @State var mostrandoOpcoesCamera = false

    return tabBarAnotacao(desenhando: $desenhando,editandoDesenho: $editandoDesenho, mostrandoActionSheet: $mostrandoActionSheet,mostrandoOpcoesCamera: $mostrandoOpcoesCamera)
}

