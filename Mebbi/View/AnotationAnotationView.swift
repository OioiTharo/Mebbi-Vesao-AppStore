import SwiftUI

struct AnotationAnotationView: View {
    var tituloCategoria: String
    var categoriaId: String
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var categoriaStore = CategoriaStore.shared
    @EnvironmentObject private var anotacaoManager: AnotacaoManager
    @State private var searchText = ""
    @EnvironmentObject var tabBarSettings: TabBarSettings
    @Binding var path: NavigationPath
    
    init(tituloCategoria: String, categoriaId: String, path: Binding<NavigationPath>) {
        self.tituloCategoria = tituloCategoria
        self.categoriaId = categoriaId
        self._path = path
    }
    
    var corCategoria: Color {
        if let categoria = categoriaStore.categorias[categoriaId] {
            let corAtual = categoria.cor
            let rgb = corAtual.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0.0 }
            return Color(red: rgb[0] / 255, green: rgb[1] / 255, blue: rgb[2] / 255)
        }
        return .white
    }
    
    private var anotacoesFiltradas: [Anotacao] {
        let anotacoes = anotacaoManager.anotacoesPorCategoria(categoriaId: categoriaId)
        if searchText.isEmpty {
            return anotacoes
        }
        return anotacoes.filter { anotacao in
            anotacao.titulo.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                barraDePesquisa(textoPesquisa: $searchText)
                    .padding()
                ScrollView {
                    VStack(spacing: 10) {
                        if anotacoesFiltradas.isEmpty {
                            Text("Nenhuma anotação disponível")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .padding()
                        } else {
                            ForEach(anotacoesFiltradas) { anotacao in
                               NavigationLink(destination: VisualizarAnotacaoView(anotacao: anotacao, excluirAnotacao: { anotacaoParaExcluir in
                                   do {
                                       try anotacaoManager.excluirAnotacao(anotacaoParaExcluir)
                                   } catch {
                                       print("Erro ao excluir anotação: \(error)")
                                   }
                                }, path: $path).navigationBarBackButtonHidden(true)) {
                                    ItemLista(
                                        titulo: anotacao.titulo,
                                        cor: corCategoria,
                                        revisao: false
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
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
                    Text(tituloCategoria)
                        .foregroundColor(Color.azulPrincipal)
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .navigationBarBackButtonHidden(true)
        }.appBackground()
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
    NavigationStack {
        AnotationAnotationView(
            tituloCategoria: "TESTE",
            categoriaId: "teste",
            path: .constant(NavigationPath())
        )
        .environmentObject(AnotacaoManager.shared)
        .environmentObject(TabBarSettings())
    }
}
