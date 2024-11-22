import Foundation
import SwiftUI
import Combine

struct Categoria: Codable, Identifiable {
    var id: UUID
    var nome: String
    var cor: String
    
    init(id: UUID = UUID(), nome: String, cor: String) {
        self.id = id
        self.nome = nome
        self.cor = cor
    }
    
    enum CodingKeys: String, CodingKey {
        case id, nome, cor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        nome = try container.decode(String.self, forKey: .nome)
        cor = try container.decode(String.self, forKey: .cor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nome, forKey: .nome)
        try container.encode(cor, forKey: .cor)
    }
}

class CategoriaStore: ObservableObject {
    static let shared = CategoriaStore()
    
    @Published var categorias: [String: Categoria] = [:]
    @Published var categoriaParaEditar: Categoria? {
        didSet {
            salvarCategorias()
        }
    }
    
    private var anotacoesPorCategoria: [String: [String]] = [:] {
        didSet {
            salvarAnotacoes()
        }
    }
    
    init() {
        carregarCategorias()
        carregarAnotacoes()
    }
    
    func salvarCategorias() {
        let categoriasParaSalvar = categorias.values.map { CategoriaSalva(nome: $0.nome, cor: $0.cor) }
        
        for categoria in categoriasParaSalvar {
            if let oldName = anotacoesPorCategoria.keys.first(where: { $0 == categoria.nome }) {
                anotacoesPorCategoria[categoria.nome] = anotacoesPorCategoria[oldName]
                anotacoesPorCategoria.removeValue(forKey: oldName)
            }
            
            if let oldName = FlashCardManager.shared.getCategoriaName(for: categoria.nome) {
                FlashCardManager.shared.updateCategoriaName(from: oldName, to: categoria.nome)
            }
        }
        
        do {
            let data = try JSONEncoder().encode(categoriasParaSalvar)
            UserDefaults.standard.set(data, forKey: "categoriasSalvas")
            UserDefaults.standard.synchronize()
        } catch {
            print("Erro ao salvar categorias: \(error)")
        }
    }
    
    private func carregarCategorias() {
        if let data = UserDefaults.standard.data(forKey: "categoriasSalvas") {
            do {
                let categoriasSalvas = try JSONDecoder().decode([CategoriaSalva].self, from: data)
                categorias = categoriasSalvas.reduce(into: [String: Categoria]()) { result, categoriaSalva in
                    result[categoriaSalva.nome] = Categoria(nome: categoriaSalva.nome, cor: categoriaSalva.cor)
                }
            } catch {
                print("Erro ao carregar categorias: \(error)")
                categorias = [:]
            }
        }
    }
    
    private func salvarAnotacoes() {
        do {
            let data = try JSONEncoder().encode(anotacoesPorCategoria)
            UserDefaults.standard.set(data, forKey: "anotacoesSalvas")
            UserDefaults.standard.synchronize()
        } catch {
            print("Erro ao salvar anotações: \(error)")
        }
    }
    
    private func carregarAnotacoes() {
        if let data = UserDefaults.standard.data(forKey: "anotacoesSalvas") {
            do {
                anotacoesPorCategoria = try JSONDecoder().decode([String: [String]].self, from: data)
            } catch {
                print("Erro ao carregar anotações: \(error)")
                anotacoesPorCategoria = [:]
            }
        }
    }
    
    func excluirCategoria(_ categoria: Categoria) {
        categorias.removeValue(forKey: categoria.nome)
        
        let anotacoesParaRemover = AnotacaoManager.shared.anotacoes.filter { $0.categoriaId == categoria.nome }
        for anotacao in anotacoesParaRemover {
            do {
                try AnotacaoManager.shared.excluirAnotacao(anotacao)
            } catch {
                print("Erro ao excluir anotação: \(error)")
            }
        }
        
        let flashCardsParaRemover = FlashCardManager.shared.flashCards.filter { $0.anotation == categoria.nome }
        for flashCard in flashCardsParaRemover {
            FlashCardManager.shared.deleteFlashCard(flashCard)
        }
        
        anotacoesPorCategoria.removeValue(forKey: categoria.nome)
        salvarCategorias()
        salvarAnotacoes()
    }
    
    func atualizarCategoria(_ categoriaAntiga: Categoria, com novoCaixa: String, e novaCor: String) {
        categorias.removeValue(forKey: categoriaAntiga.nome)
        
        let novaCategoria = Categoria(id: categoriaAntiga.id, nome: novoCaixa, cor: novaCor)
        categorias[novoCaixa] = novaCategoria
        
        if categoriaAntiga.nome != novoCaixa {
            anotacoesPorCategoria[novoCaixa] = anotacoesPorCategoria[categoriaAntiga.nome]
            anotacoesPorCategoria.removeValue(forKey: categoriaAntiga.nome)
        }
        
        FlashCardManager.shared.updateCategoriaName(from: categoriaAntiga.nome, to: novoCaixa)
        
        let anotacaoManager = AnotacaoManager.shared
        var anotacoesParaAtualizar: [Anotacao] = []
        
        for anotacao in anotacaoManager.anotacoes where anotacao.categoriaId == categoriaAntiga.nome {
            let anotacaoAtualizada = Anotacao(
                id: anotacao.id,
                titulo: anotacao.titulo,
                categoriaId: novoCaixa,
                conteudos: anotacao.conteudos,
                dataAnotacao: anotacao.dataAnotacao,
                repeticao: anotacao.repeticao,
                datasRevisao: anotacao.datasRevisao
            )
            anotacoesParaAtualizar.append(anotacaoAtualizada)
        }
        
        for anotacao in anotacoesParaAtualizar {
            do {
                try anotacaoManager.atualizarAnotacao(anotacao)
            } catch {
                print("Erro ao atualizar anotação: \(error)")
            }
        }
        
        salvarCategorias()
        salvarAnotacoes()
        objectWillChange.send()
    }
    
    func removerAnotacaoDaCategoria(_ anotacao: Anotacao) {
        if let categoria = categorias[anotacao.categoriaId] {
            if let index = anotacoesPorCategoria[categoria.nome]?.firstIndex(of: anotacao.titulo) {
                anotacoesPorCategoria[categoria.nome]?.remove(at: index)
                salvarAnotacoes()
            }
        }
    }
}

struct CategoriaSalva: Codable {
    let nome: String
    let cor: String
}

extension CategoriaStore {
    func getCategoriaColor(_ categoriaId: String) -> Color {
        if let categoria = categorias[categoriaId] {
            return ColorSelection().colorFromRGBString(categoria.cor)
        }
        return .white
    }
}
