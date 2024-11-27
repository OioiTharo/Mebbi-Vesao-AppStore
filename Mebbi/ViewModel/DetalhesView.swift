import Foundation
import SwiftUI

struct DetalhesView: View {
    let titulo: String
    @State private var anotacao: String
    let modo: NovaAnotacaoView.Modo
    let existingAnotacao: Anotacao?
    @EnvironmentObject var tabBarSettings: TabBarSettings
    @EnvironmentObject private var anotacaoManager: AnotacaoManager
    @State private var dataAnotacao: Date
    @State private var selecionadaRepeticao: PadraoRepeticao
    @State private var mostrarSheetRepeticao = false
    @State private var categoriaSelecionada: String
    @State private var datasFuturas: [Date] = []
    @ObservedObject private var categoriaStore = CategoriaStore.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var path: NavigationPath
    @Binding var isNovaAnotacaoPresented: Bool
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    let conteudoFormatado: Data?
    
    init(modo: NovaAnotacaoView.Modo, titulo: String, anotacao: String, conteudoFormatado: Data? = nil, existingAnotacao: Anotacao? = nil, path: Binding<NavigationPath>, isNovaAnotacaoPresented: Binding<Bool>) {
        self.modo = modo
        self.titulo = titulo
        self.conteudoFormatado = conteudoFormatado
        self.existingAnotacao = existingAnotacao
        self._path = path
        self._isNovaAnotacaoPresented = isNovaAnotacaoPresented
        _anotacao = State(initialValue: anotacao)
        
        if let existing = existingAnotacao {
            _dataAnotacao = State(initialValue: existing.dataAnotacao)
            _selecionadaRepeticao = State(initialValue: existing.repeticao)
            _categoriaSelecionada = State(initialValue: existing.categoriaId)
            
            let datas = calcularDatasFuturas(repeticao: existing.repeticao, dataAtual: existing.dataAnotacao)
            _datasFuturas = State(initialValue: datas)
        } else {
            _dataAnotacao = State(initialValue: Date.now)
            _selecionadaRepeticao = State(initialValue: .nenhuma)
            _categoriaSelecionada = State(initialValue: "Nenhuma")
            _datasFuturas = State(initialValue: [])
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Data da Anotação")
                    .foregroundColor(Color.gw)
                Spacer()
                DatePicker("", selection: $dataAnotacao, in: ...Date.now, displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color.azulPrincipal)
                    .onChange(of: dataAnotacao) { _ in
                        calcularEAtualizarDatas()
                    }
            }
            .padding(.vertical, 2)
            .padding(.top, 20)
            Divider().background(Color.azulPrincipal)
            
            HStack {
                Text("Categoria")
                    .foregroundColor(Color.gw)
                Spacer()
                NavigationLink(
                    destination: SelecionarCategoriaView(categoriaStore: categoriaStore, categoriaSelecionada: $categoriaSelecionada)
                        .navigationBarBackButtonHidden(true)
                ) {
                    Text(categoriaSelecionada)
                        .foregroundColor(Color.azulPrincipal)
                    Image(systemName: "chevron.forward")
                        .foregroundColor(Color.azulPrincipal)
                }
            }
            .padding(.vertical, 2)
            Divider().background(Color.azulPrincipal)
            
            HStack {
                Button(action: {
                    mostrarSheetRepeticao = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(Color.azulPrincipal)
                }
                .sheet(isPresented: $mostrarSheetRepeticao) {
                    RepeticaoSheet()
                        .presentationDetents([.medium])
                }
                Text("Repetição Espaçada")
                    .foregroundColor(Color.gw)
                Spacer()
                
                let opcoesRepeticao: [PadraoRepeticao] = [.padrao1, .padrao2, .padrao3, .nenhuma]
                Menu {
                    ForEach(opcoesRepeticao, id: \.self) { opcao in
                        Button(opcao.rawValue) {
                            selecionadaRepeticao = opcao
                            calcularEAtualizarDatas()
                        }
                    }
                } label: {
                    HStack {
                        Text(selecionadaRepeticao.rawValue)
                            .foregroundColor(Color.azulPrincipal)
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(Color.azulPrincipal)
                    }
                }
            }
            .padding(.vertical, 2)
            
            if !datasFuturas.isEmpty {
                Divider().background(Color.azulPrincipal)
                HStack(alignment: .top) {
                    Text("Datas de Revisão:")
                        .font(.headline)
                        .foregroundColor(Color.azulPrincipal)
                    Spacer()
                    VStack(alignment: .trailing) {
                        ForEach(datasFuturas, id: \.self) { data in
                            Text(formatarData(data))
                                .foregroundColor(Color.cinza)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .appBackground()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    botaoVoltar()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Detalhes")
                    .foregroundColor(Color.azulPrincipal)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: salvarEVoltar) {
                    HStack {
                        Text(categoriaSelecionada == "Nenhuma" ? "Salvar" : "Salvar")
                            .foregroundStyle(categoriaSelecionada == "Nenhuma" ? Color.azulPrincipal.opacity(0.5) : Color.azulPrincipal)
                        Image(systemName: "chevron.forward")
                            .foregroundStyle(categoriaSelecionada == "Nenhuma" ? Color.azulPrincipal.opacity(0.5) : Color.azulPrincipal)
                    }
                }
                .disabled(categoriaSelecionada == "Nenhuma")
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Erro ao Salvar", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
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
    
    private func calcularEAtualizarDatas() {
        datasFuturas = calcularDatasFuturas(repeticao: selecionadaRepeticao, dataAtual: dataAnotacao)
    }
    
    private func formatarData(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: data)
    }
    
    
    private func salvarEVoltar() {
        let datasRevisao = datasFuturas.map { DataRevisao(data: $0, revisao: false) }
        
        do {
            if modo == .edicao, let existing = existingAnotacao {
                let updatedAnotacao = Anotacao(
                    id: existing.id,
                    titulo: titulo,
                    categoriaId: categoriaSelecionada,
                    conteudos: anotacao,
                    conteudoFormatado: conteudoFormatado,  
                    dataAnotacao: dataAnotacao,
                    repeticao: selecionadaRepeticao,
                    datasRevisao: datasRevisao
                )
                try anotacaoManager.atualizarAnotacao(updatedAnotacao)
                
            } else {
                let novaAnotacao = Anotacao(
                    id: UUID(),
                    titulo: titulo,
                    categoriaId: categoriaSelecionada,
                    conteudos: anotacao,
                    conteudoFormatado: conteudoFormatado,
                    dataAnotacao: dataAnotacao,
                    repeticao: selecionadaRepeticao,
                    datasRevisao: datasRevisao
                )
                try anotacaoManager.adicionarAnotacao(novaAnotacao)
                
            }
            
            path.removeLast(path.count)
            isNovaAnotacaoPresented = false
            presentationMode.wrappedValue.dismiss()
            
        } catch {
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
}
