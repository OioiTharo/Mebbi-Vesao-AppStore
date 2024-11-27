import SwiftUI
import Combine

struct SelecionarCategoriaView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var categoriaStore: CategoriaStore
    @Binding var categoriaSelecionada: String
    @State private var mostrarSheet = false
    @EnvironmentObject var tabBarSettings: TabBarSettings

    
    var body: some View {
        NavigationView {
            ZStack{
                Color.background
                    .edgesIgnoringSafeArea(.all)
                
                if categoriaStore.categorias.isEmpty {
                    VStack{
                        Spacer()
                        Image("cateVazia")
                            .resizable()
                            .frame(width: 200, height: 200)
                        Text("Crie uma categoria clicando no botão +")
                            .foregroundColor(.textoVazio)
                            .font(.body)
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                        Spacer()
                    }
                } else {
                    VStack {
                        HStack {
                            Text("Escolha sua categoria")
                                .foregroundColor(.azulPrincipal)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVStack {
                            ForEach(categoriaStore.categorias.sorted(by: { $0.key < $1.key }), id: \.key) { key, categoria in
                                HStack {
                                    if let color = Color(hex: categoria.cor) { // Convertendo a cor
                                        let corAtual = categoria.cor
                                        let rgb = corAtual.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0.0 }
                                        let color = Color(red: rgb[0] / 255, green: rgb[1] / 255, blue: rgb[2] / 255)
                                        
                                        Circle()
                                            .fill(color)
                                            .frame(width: 25)
                                    }
                                    
                                    ZStack {
                                        Text(categoria.nome)
                                            .font(.title3)
                                            .foregroundColor(Color.azulPrincipal)
                                            .padding(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if categoria.nome == categoriaSelecionada {
                                            let textSize = (categoria.nome as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
                                            HStack {
                                                Rectangle()
                                                    .fill(Color.azulPrincipal.opacity(0.2))
                                                    .frame(width: textSize.width + 35, height: 40)
                                                    .cornerRadius(10)
                                                Spacer()
                                            }
                                        }
                                    }.appBackground()
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            categoriaSelecionada = (categoriaSelecionada == categoria.nome) ? "Nenhuma" : categoria.nome
                                        }
                                }
                            }
                            .frame(height: 60)
                            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 6, trailing: 20))
                        }.padding(.horizontal,20)
                        
                            .listStyle(PlainListStyle())
                        Spacer()
                    }
                }
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
                    Text("Categorias")
                        .foregroundColor(.azulPrincipal)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    
                    Button(action: {
                        categoriaStore.categoriaParaEditar = nil
                        mostrarSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.azulPrincipal)
                    }
                    .sheet(isPresented: $mostrarSheet) {
                        CategoriaSheet(categoriaStore: categoriaStore)
                            .environmentObject(ColorSelection())
                            .presentationDetents([.fraction(0.8), .height(500), .large])
                    }
                }
            }
            .environmentObject(categoriaStore)
            .environmentObject(ColorSelection())
        }.onAppear {
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
    struct PreviewWrapper: View {
        @State var categoriaTemporaria = "Nenhuma"
        
        var body: some View {
            SelecionarCategoriaView(categoriaStore: CategoriaStore.shared, categoriaSelecionada: $categoriaTemporaria)
        }
    }
    
    return PreviewWrapper()
}
