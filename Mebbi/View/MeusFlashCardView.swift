import SwiftUI

struct MeusFlashCardView: View {
    @ObservedObject var categoriaStore = CategoriaStore.shared
    @ObservedObject var anotacaoManager = AnotacaoManager.shared
    @EnvironmentObject var tabBarSettings: TabBarSettings
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Meus FlashCards")
                        .foregroundColor(.azulPrincipal)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top,30)
                
                if categoriaStore.categorias.isEmpty {
                    VStack {
                        Spacer()
                        Image("flashVazio")
                            .resizable()
                            .frame(width: 200, height: 200)
                        Text("Tenha anotações para criar flashcards")
                            .foregroundColor(.textoVazio)
                            .font(.body)
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                        Spacer()
                    }
                } else {
                    HStack {
                        Text("Qual categoria você deseja estudar?")
                            .foregroundColor(.azulPrincipal.opacity(0.5))
                            .font(.footnote)
                            .padding(.horizontal, 20)
                            .padding(.top, -18)
                        Spacer()
                    }
                    
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(categoriaStore.categorias.sorted(by: { $0.key < $1.key }), id: \.key) { key, categoria in
                                NavigationLink(destination: AnotationFlashCardsView(
                                    tituloCategoria: categoria.nome,
                                    categoriaId: categoria.nome
                                ).navigationBarBackButtonHidden(true)) {
                                    
                                    let corAtual = categoria.cor
                                    let rgb = corAtual.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0.0 }
                                    let color = Color(red: rgb[0] / 255, green: rgb[1] / 255, blue: rgb[2] / 255)
                                    
                                    categoriaFlashcards(
                                        titulo: categoria.nome,
                                        corInferior: color
                                    )
                                }
                            }
                            
                            
                        }
                        .padding()
                    }
                }
                
            }.appBackground()
        }
        .onAppear {
            tabBarSettings.forceShow() 
        }
    }
}
