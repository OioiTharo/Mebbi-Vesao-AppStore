import SwiftUI

struct AnotationFlashCardsView: View {
    var tituloCategoria: String
    var categoriaId: String
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var categoriaStore = CategoriaStore.shared
    @ObservedObject var anotacaoManager = AnotacaoManager.shared
    @State private var searchText = ""
    @EnvironmentObject var tabBarSettings: TabBarSettings

    init(tituloCategoria: String, categoriaId: String) {
        self.tituloCategoria = tituloCategoria
        self.categoriaId = categoriaId
        print("AnotationFlashCardsView inicializada com categoria: \(categoriaId)")
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
                            Text("Escolha uma anotação para criar o Flashcard")
                                .foregroundColor(Color.azulPrincipal)
                                .font(.subheadline)
                                .padding()
                            
                            ForEach(anotacoesFiltradas) { anotacao in
                                NavigationLink(
                                    destination: FlashCardView(anotation: anotacao.titulo)
                                        .navigationBarBackButtonHidden(true)
                                ) {
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
            .onAppear {
                anotacaoManager.carregarAnotacoes()
                anotacaoManager.objectWillChange.send()
            }
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
    AnotationFlashCardsView(tituloCategoria: "TESTE", categoriaId: "teste")
}
