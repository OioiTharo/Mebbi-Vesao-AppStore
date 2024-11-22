import Foundation
import SwiftUI

struct DataRevisao: Codable {
    let data: Date
    let revisao: Bool
}

enum PadraoRepeticao: String, Codable {
    case padrao1 = "1-7-30"
    case padrao2 = "1-3-7-14"
    case padrao3 = "2-4-8-16-32"
    case nenhuma = "Nenhuma"
    
    var intervalos: [Int] {
        switch self {
        case .padrao1: return [1, 7, 30]
        case .padrao2: return [1, 3, 7, 14]
        case .padrao3: return [2, 4, 8, 16, 32]
        case .nenhuma: return []
        }
    }
}

struct Anotacao: Identifiable, Codable {
    let id: UUID
    let titulo: String
    let categoriaId: String
    let conteudos: String
    let conteudoFormatado: Data?
    let dataAnotacao: Date
    let repeticao: PadraoRepeticao
    var datasRevisao: [DataRevisao]
    
    init(
        id: UUID,
        titulo: String,
        categoriaId: String,
        conteudos: String,
        conteudoFormatado: Data? = nil,
        dataAnotacao: Date = Date(),
        repeticao: PadraoRepeticao = .nenhuma,
        datasRevisao: [DataRevisao]? = nil
    ) {
        self.id = id
        self.titulo = titulo
        self.categoriaId = categoriaId
        self.conteudos = conteudos
        self.conteudoFormatado = conteudoFormatado
        self.dataAnotacao = dataAnotacao
        self.repeticao = repeticao
        self.datasRevisao = datasRevisao ?? Anotacao.gerarDatasRevisao(dataInicial: dataAnotacao, repeticao: repeticao)
    }
    
    static func gerarDatasRevisao(dataInicial: Date, repeticao: PadraoRepeticao) -> [DataRevisao] {
        var datas = [DataRevisao]()
        let calendar = Calendar.current
        
        for intervalo in repeticao.intervalos {
            if let dataRevisao = calendar.date(byAdding: .day, value: intervalo, to: dataInicial) {
                datas.append(DataRevisao(data: dataRevisao, revisao: false))
            }
        }
        
        return datas
    }
}



extension Anotacao {
    func formatarData() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dataAnotacao)
    }
}

class AnotacaoManager: ObservableObject {
    static let shared = AnotacaoManager()
    @Published var anotacoes: [Anotacao] = []
    private let userDefaultsKey = "anotacoes"
    
    init() {
        carregarAnotacoes()
    }
    
    func carregarAnotacoes() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode([Anotacao].self, from: data)
                DispatchQueue.main.async {
                    self.anotacoes = decoded
                }
            } catch {
                print("Erro ao decodificar anotações: \(error)")
                self.anotacoes = []
            }
        } else {
            self.anotacoes = []
        }
    }
    
    func adicionarAnotacao(_ anotacao: Anotacao) throws {
        anotacoes.append(anotacao)
        try salvarAnotacoes()
        objectWillChange.send()
        NotificationHandler.shared.checkAndScheduleNotifications(for: obterTodasDatasDeRevisao())
    }
    
    func atualizarAnotacao(_ anotacao: Anotacao) throws {
        if let index = anotacoes.firstIndex(where: { $0.id == anotacao.id }) {
            anotacoes[index] = anotacao
            try salvarAnotacoes()
            objectWillChange.send()
            NotificationHandler.shared.checkAndScheduleNotifications(for: obterTodasDatasDeRevisao())
        }
    }
    
    private func salvarAnotacoes() throws {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let encoded = try encoder.encode(anotacoes)
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Erro ao codificar anotações: \(error)")
            throw error
        }
    }
    
    func excluirAnotacao(_ anotacao: Anotacao) throws {
        if let index = anotacoes.firstIndex(where: { $0.id == anotacao.id }) {
            anotacoes.remove(at: index)
            try salvarAnotacoes()
            objectWillChange.send()
            CategoriaStore.shared.removerAnotacaoDaCategoria(anotacao)
        }
    }
    
    func anotacoesPorCategoria(categoriaId: String) -> [Anotacao] {
        return anotacoes.filter { $0.categoriaId == categoriaId }
    }
    
    func anotacoesPorData(data: Date) -> [Anotacao] {
        let calendar = Calendar.current
        return anotacoes.filter { anotacao in
            calendar.isDate(anotacao.dataAnotacao, inSameDayAs: data)
        }
    }
    func atualizarAnotacoes() {
        carregarAnotacoes()
    }
    
    func obterTodasDatasDeRevisao() -> [Date] {
        var todasDatas: [Date] = []
        
        for anotacao in anotacoes {
            for dataRevisao in anotacao.datasRevisao {
                todasDatas.append(dataRevisao.data)
            }
        }
        
        return todasDatas
    }
}
