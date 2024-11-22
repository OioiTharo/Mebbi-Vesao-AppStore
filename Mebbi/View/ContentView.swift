import SwiftUI

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ContentView: View {
    @StateObject private var anotacaoManager = AnotacaoManager.shared
    @State private var dataAnotacao = Date.now
    @State private var isScrolled = false
    @StateObject private var categoriaStore = CategoriaStore.shared
    @StateObject private var colorSelection = ColorSelection()
    @State private var searchText = ""
    @State private var isSearching = false
    @EnvironmentObject var tabBarSettings: TabBarSettings
    @State private var path = NavigationPath()
    
    private var anotacoesCriadasHoje: [Anotacao] {
        let calendar = Calendar.current
        return anotacaoManager.anotacoes.filter { anotacao in
            calendar.isDate(anotacao.dataAnotacao, inSameDayAs: dataAnotacao)
        }
    }
    
    private var anotacoesDeRevisao: [Anotacao] {
        let calendar = Calendar.current
        return anotacaoManager.anotacoes.filter { anotacao in
            anotacao.datasRevisao.contains { revisao in
                calendar.isDate(revisao.data, inSameDayAs: dataAnotacao)
            } && !calendar.isDate(anotacao.dataAnotacao, inSameDayAs: dataAnotacao)
        }
    }
    
    private var anotacoesPesquisadas: [Anotacao] {
        if searchText.isEmpty {
            return []
        }
        return anotacaoManager.anotacoes.filter { anotacao in
            anotacao.titulo.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                navBarMenu(searchText: $searchText, isSearching: $isSearching, path: $path)
                    .frame(height: 150)
                
                ScrollView {
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollViewOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                    }
                    .frame(height: 0)
                    
                    VStack {
                        if isSearching {
                            ForEach(anotacoesPesquisadas) { anotacao in
                                NavigationLink(destination: VisualizarAnotacaoView(anotacao: anotacao, excluirAnotacao: { anotacaoParaExcluir in
                                    do {
                                        try anotacaoManager.excluirAnotacao(anotacaoParaExcluir)
                                    } catch {
                                        print("Erro ao excluir anotação: \(error)")
                                    }
                                }, path: $path).navigationBarBackButtonHidden(true)) {
                                    ItemLista(
                                        titulo: anotacao.titulo,
                                        cor: categoriaStore.getCategoriaColor(anotacao.categoriaId),
                                        revisao: false
                                    )
                                    .padding(.horizontal)
                                }
                            }
                            
                            if anotacoesPesquisadas.isEmpty {
                                Text("Nenhuma anotação encontrada")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        } else {
                            HStack {
                                Text("Data Selecionada:")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.azulPrincipal)
                                DatePicker(
                                    "",
                                    selection: $dataAnotacao,
                                    in: Calendar.current.date(byAdding: .year, value: -5, to: Date.now)!...Calendar.current.date(byAdding: .year, value: 1, to: Date.now)!,
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                                .tint(Color.azulPrincipal)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical)
                            
                            if !anotacoesDeRevisao.isEmpty {
                                VStack(alignment: .leading) {
                                    ForEach(anotacoesDeRevisao) { anotacao in
                                        NavigationLink(destination: VisualizarAnotacaoView(anotacao: anotacao, excluirAnotacao: { anotacaoParaExcluir in
                                            do {
                                                try anotacaoManager.excluirAnotacao(anotacaoParaExcluir)
                                            } catch {
                                                print("Erro ao excluir anotação: \(error)")
                                            }
                                        }, path: $path).navigationBarBackButtonHidden(true)) {
                                            ItemLista(
                                                titulo: anotacao.titulo,
                                                cor: categoriaStore.getCategoriaColor(anotacao.categoriaId),
                                                revisao: true
                                            )
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                            
                            if !anotacoesCriadasHoje.isEmpty {
                                VStack(alignment: .leading) {
                                    ForEach(anotacoesCriadasHoje) { anotacao in
                                        NavigationLink(destination: VisualizarAnotacaoView(anotacao: anotacao, excluirAnotacao: { anotacaoParaExcluir in
                                            do {
                                                try anotacaoManager.excluirAnotacao(anotacaoParaExcluir)
                                            } catch {
                                                print("Erro ao excluir anotação: \(error)")
                                            }
                                        }, path: $path).navigationBarBackButtonHidden(true)) {
                                            ItemLista(
                                                titulo: anotacao.titulo,
                                                cor: categoriaStore.getCategoriaColor(anotacao.categoriaId),
                                                revisao: false
                                            )
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                            
                            if anotacoesCriadasHoje.isEmpty && anotacoesDeRevisao.isEmpty {
                                VStack {
                                    Spacer()
                                    Image("anotacaoVazia")
                                        .resizable()
                                        .frame(width: 200, height: 200)
                                        .padding(.top, 150)
                                    Text("Crie uma anotação nesta data no botão +")
                                        .foregroundColor(.textoVazio)
                                        .font(.body)
                                        .padding(.horizontal, 20)
                                        .padding(.top, 40)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                    withAnimation {
                        isScrolled = value < -1
                    }
                }
                .onAppear {
                    tabBarSettings.forceShow()
                }
                .onAppear {
                    anotacaoManager.atualizarAnotacoes()
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
        .environmentObject(categoriaStore)
        .environmentObject(colorSelection)
        .environmentObject(anotacaoManager)
        .appBackground()
    }
}

#Preview {
    ContentView()
}
