import SwiftUI

struct TabBar: View {
    @Binding var isPresented: Bool
    @Binding var telaAtual: String
    @Binding var path: NavigationPath
    
    var body: some View {
        if isPresented {
            VStack {
                ZStack {
                    Color.white
                        .shadow(color: .white, radius: 10)
                    
                    HStack {
                        Button(action: {
                            telaAtual = "anotacao"
                            path = NavigationPath()
                        }) {
                            VStack {
                                Image(systemName: telaAtual == "anotacao" ? "doc.text.fill" : "doc.text")
                                    .opacity(telaAtual == "anotacao" ? 1 : 0.5)
                                    .foregroundColor(Color.azulPrincipal)
                                    .font(.system(size: 18))
                                    .padding(.bottom, 2)
                                Text(telaAtual == "anotacao" ? "Anotações" : "Anotações")
                                    .foregroundStyle(telaAtual == "anotacao" ? Color.azulPrincipal : Color.azulPrincipal.opacity(0.5))
                                    .font(.system(size: 12))
                            }
                        }
                        .disabled(telaAtual == "anotacao")
                        .padding(.trailing, 25)
                        
                        Button(action: {
                            telaAtual = "flashs"
                            path = NavigationPath()
                        }) {
                            VStack {
                                Image(telaAtual == "flashs" ? "flash.fill" : "flash")
                                    .opacity(telaAtual == "flashs" ? 1 : 0.5)
                                    .font(.system(size: 20))
                                    .padding(.bottom, 2)
                                Text(telaAtual == "flashs" ? "Flashcards" : "Flashcards")
                                    .foregroundStyle(telaAtual == "flashs" ? Color.azulPrincipal : Color.azulPrincipal.opacity(0.5))
                                    .font(.system(size: 12))
                            }
                        }
                        .disabled(telaAtual == "flashs")
                        .padding(.horizontal)
                        
                        Button(action: {
                            telaAtual = "cate"
                            path = NavigationPath()
                        }) {
                            VStack {
                                Image(systemName: telaAtual == "cate" ? "tray.fill" : "tray")
                                    .opacity(telaAtual == "cate" ? 1 : 0.5)
                                    .foregroundColor(Color.azulPrincipal)
                                    .font(.system(size: 20))
                                    .padding(.bottom, 2)
                                Text(telaAtual == "cate" ? "Categorias" : "Categorias")
                                    .foregroundStyle(telaAtual == "cate" ? Color.azulPrincipal : Color.azulPrincipal.opacity(0.5))
                                    .font(.system(size: 12))
                            }
                        }
                        .disabled(telaAtual == "cate")
                        .padding(.leading, 25)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
                .background(Color.clear)
            }
        }
    }
}

#Preview {
    @State var isPresented = true
    @State var telaAtual = "cate"
    @State var path = NavigationPath()
    
    return TabBar(
        isPresented: $isPresented,
        telaAtual: $telaAtual,
        path: $path
    )
}
