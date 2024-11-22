
import SwiftUI

extension View {
    func appBackground() -> some View {
        self.background(Color.background)
    }
}

struct CategoriaView: View {
    @State private var mostrarSheet = false
    @ObservedObject private var categoriaStore = CategoriaStore.shared
    @EnvironmentObject var colorSelection: ColorSelection
    @ObservedObject var anotacaoManager = AnotacaoManager.shared
    @EnvironmentObject var tabBarSettings: TabBarSettings
    @State private var categoriaParaDeletar: String? = nil
    @StateObject private var localColorSelection = ColorSelection()
    @State private var mostrarAlerta = false
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Categorias")
                        .foregroundColor(.azulPrincipal)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        categoriaStore.categoriaParaEditar = nil
                        mostrarSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color.azulPrincipal)
                            .font(.title)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                
                if categoriaStore.categorias.isEmpty {
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
                } else {
                    List {
                        ForEach(Array(categoriaStore.categorias.values), id: \.id) { categoria in
                            NavigationLink(
                                destination: AnotationAnotationView(
                                    tituloCategoria: categoria.nome,
                                    categoriaId: categoria.nome,
                                    path: $path
                                )
                                .appBackground()
                                .navigationBarBackButtonHidden(true)
                            ) {
                                let corAtual = categoria.cor
                                let rgb = corAtual.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0.0 }
                                let color = Color(red: rgb[0] / 255, green: rgb[1] / 255, blue: rgb[2] / 255)
                                
                                HStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 30, height: 30)
                                    
                                    Text(categoria.nome)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                .background(Color.background)
                                .padding(.vertical, 4)
                            }
                            .swipeActions {
                                Button("Deletar") {
                                    categoriaParaDeletar = categoria.nome
                                    mostrarAlerta.toggle()
                                }.tint(.red)
                                
                                Button("Editar") {
                                    categoriaStore.categoriaParaEditar = categoria
                                    mostrarSheet.toggle()
                                }.tint(.gray)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.background)
                        }
                        .onDelete(perform: deleteCategoria)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.background)
                    .navigationBarBackButtonHidden(false)
                    .appBackground()
                    Spacer()
                }
            }
            .appBackground()
        }
        .sheet(isPresented: $mostrarSheet) {
            CategoriaSheet(categoriaStore: categoriaStore)
                .environmentObject(localColorSelection)
        }
        .alert(isPresented: $mostrarAlerta) {
            Alert(
                title: Text("Tem certeza que deseja deletar '\(categoriaParaDeletar ?? "")'? 🤔"),
                message: Text("Você pode ter anotações e flashcards relacionados a essa categoria."),
                primaryButton: .destructive(Text("Deletar")) {
                    if let categoriaNome = categoriaParaDeletar {
                        if let categoria = categoriaStore.categorias[categoriaNome] {
                            categoriaStore.excluirCategoria(categoria)
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            tabBarSettings.forceShow()
        }
    }
    
    private func deleteCategoria(at offsets: IndexSet) {
        offsets.forEach { index in
            let categoria = Array(categoriaStore.categorias.values)[index]
            categoriaStore.excluirCategoria(categoria)
        }
    }
}

struct CategoriaView_Previews: PreviewProvider {
    static var previews: some View {
        let categoriaStore = CategoriaStore.shared
        let colorSelection = ColorSelection()
        
        colorSelection.corSelecionada = "255, 255, 255"
        
        return NavigationStack {
            CategoriaView(path: .constant(NavigationPath()))
                .environmentObject(categoriaStore)
                .environmentObject(colorSelection)
        }
    }
}
