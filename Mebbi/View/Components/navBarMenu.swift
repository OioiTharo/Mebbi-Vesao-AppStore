import Foundation
import  SwiftUI

struct navBarMenu: View {
    @State private var mostrarPesquisa = false
    @ObservedObject var anotacaoManager = AnotacaoManager.shared
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @Binding var path: NavigationPath
    @State private var mostrarSheet = false
    
    private var anotacoesFiltradas: [Anotacao] {
        let anotacoes = anotacaoManager.anotacoes
        if searchText.isEmpty {
            return anotacoes
        }
        return anotacoes.filter { anotacao in
            anotacao.titulo.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    if mostrarPesquisa {
                        barraDePesquisa(textoPesquisa: $searchText)
                            .frame(width: 300)
                            .onChange(of: searchText) { _ in
                                isSearching = !searchText.isEmpty
                            }
                            .padding(.bottom)
                        Button("Cancelar") {
                            withAnimation {
                                mostrarPesquisa.toggle()
                                searchText = ""
                                isSearching = false
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.trailing)
                        .padding(.bottom)
                    } else {
                        Text("Anotações")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .padding(.leading, 20)
                            .fontWeight(.bold)
                        Spacer()
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .font(.title2)
                            .onTapGesture {
                                withAnimation {
                                    mostrarPesquisa.toggle()
                                }
                            }
                        
                        NavigationLink(destination: NovaAnotacaoView(path: $path).navigationBarBackButtonHidden(true)) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                
                if !mostrarPesquisa {
                    HStack(){
                        Button(action: {
                            mostrarSheet = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.white)
                        }
                        .sheet(isPresented: $mostrarSheet) {
                            TermosDeUso()
                        }
                        Text("Crie anotações e revise conteúdos do dia")
                            .foregroundColor(.white)
                            .font(.footnote)
                        Spacer()
                    }.padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 15)
            .background(Color.azulPrincipal)
        }
    }
}

struct navBarMenu_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                navBarMenu(
                    searchText: .constant(""),
                    isSearching: .constant(false),
                    path: .constant(NavigationPath())
                )
                Spacer()
            }
        }
        .previewDisplayName("Estado Normal")
        
        NavigationView {
            VStack {
                navBarMenu(
                    searchText: .constant("Teste"),
                    isSearching: .constant(true),
                    path: .constant(NavigationPath())
                )
                Spacer()
            }
        }
        .previewDisplayName("Estado de Pesquisa")
    }
}
