import SwiftUI

struct CategoriaSheet: View {
    @StateObject var categoriaStore = CategoriaStore.shared
    @State private var novaCategoria: String = ""
    @EnvironmentObject var colorSelection: ColorSelection
    @Environment(\.presentationMode) var presentationMode
    @State private var corSelecionada: String? = nil
    
    @State private var mostrarAlerta = false
    @State private var mensagemAlerta: String = ""
    
    var body: some View {
        VStack {
            Text(categoriaStore.categoriaParaEditar == nil ? "Criar Categoria" : "Editar Categoria")
                .foregroundColor(Color.azulPrincipal)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 25)
            
            HStack {
                Text("Nome")
                    .foregroundColor(Color.azulPrincipal)
                    .font(.title3)
                    .padding(.trailing, 5)
                TextField("Nome da Categoria", text: $novaCategoria)
                    .foregroundColor(Color.wb)
                    .onChange(of: novaCategoria) { newValue in
                        if newValue.count > 20 {
                            novaCategoria = String(newValue.prefix(20))
                        }
                    }
            }.padding(.horizontal, 30)
            
            if novaCategoria.count == 20 {
                Text("O título atingiu o limite de 20 caracteres.")
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            CoresEscolha()
                .frame(width: .infinity)
            
            Button("Salvar") {
                saveCategoria()
            }
            .foregroundColor(Color.azulPrincipal)
            .font(.title3)
            .padding(.top, 5)
            
            Spacer()
        }.appBackground()
        .onAppear {
            if let categoria = categoriaStore.categoriaParaEditar {
                            novaCategoria = categoria.nome
                            corSelecionada = categoria.cor
                            colorSelection.corSelecionada = categoria.cor
                    }
                }
        
        .alert(isPresented: $mostrarAlerta) {
                   Alert(
                       title: Text("A categoria \(novaCategoria) já existe 🤨"),
                       message: Text(mensagemAlerta),
                       dismissButton: .default(Text("OK"))
                   )
               }
        
    }
    
    private func saveCategoria() {
        guard !novaCategoria.isEmpty,
              let corSelecionada = colorSelection.corSelecionada else {
            return
        }

        if categoriaStore.categorias.keys.contains(novaCategoria) {
            mensagemAlerta = "Escolha um outro nome para criar uma nova categoria."
            mostrarAlerta = true
            return
        }

        if let categoriaSendoEditada = categoriaStore.categoriaParaEditar {
            categoriaStore.atualizarCategoria(categoriaSendoEditada, com: novaCategoria, e: corSelecionada)
        } else {
            let novaCategoriaObj = Categoria(nome: novaCategoria, cor: corSelecionada)
            categoriaStore.categorias[novaCategoria] = novaCategoriaObj
            categoriaStore.salvarCategorias()
        }

        novaCategoria = ""
        colorSelection.corSelecionada = nil 
        presentationMode.wrappedValue.dismiss()
    }


}

struct CategoriaSheet_Previews: PreviewProvider {
    static var previews: some View {
        let colorSelection = ColorSelection()
        return CategoriaSheet(categoriaStore: CategoriaStore())
            .environmentObject(colorSelection) 
    }
}
