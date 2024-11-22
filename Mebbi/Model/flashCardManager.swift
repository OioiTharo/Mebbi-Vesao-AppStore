import Foundation

struct FlashCard: Codable, Identifiable, Hashable {
    let id: UUID
    var question: String
    var answer: String
    var anotation: String
    
    init(id: UUID = UUID(), question: String, answer: String, anotation: String) {
        self.id = id
        self.question = question
        self.answer = answer
        self.anotation = anotation
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FlashCard, rhs: FlashCard) -> Bool {
        return lhs.id == rhs.id
    }
}

class FlashCardManager: ObservableObject {
    static let shared = FlashCardManager(categoriaStore: CategoriaStore.shared)
    @Published var flashCards: [FlashCard] = []
    private let userDefaultsKey = "savedFlashCards"
    private let categoriaStore: CategoriaStore
    
    init(categoriaStore: CategoriaStore) {
        self.categoriaStore = categoriaStore
        loadFlashCards()
    }
    
    private func loadFlashCards() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decoded = try? JSONDecoder().decode([FlashCard].self, from: data) {
                self.flashCards = decoded
            }
        }
    }
    
    func saveFlashCards() {
        if let encoded = try? JSONEncoder().encode(flashCards) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            objectWillChange.send()
        }
    }
    
    func addFlashCard(question: String, answer: String, anotation: String) {
        let flashCard = FlashCard(question: question, answer: answer, anotation: anotation)
        flashCards.insert(flashCard, at: 0)
        saveFlashCards()
    }
    
    func deleteFlashCard(_ flashCard: FlashCard) {
        flashCards.removeAll { $0.id == flashCard.id }
        saveFlashCards()
    }
    
    func editFlashCard(_ card: FlashCard, newQuestion: String, newAnswer: String) {
        if let index = flashCards.firstIndex(where: { $0.id == card.id }) {
            // Remove o cartão da posição atual
            flashCards.remove(at: index)
            // Cria um novo cartão com o mesmo ID e os novos dados
            let updatedCard = FlashCard(id: card.id,
                                        question: newQuestion,
                                        answer: newAnswer,
                                        anotation: card.anotation)
            // Insere o cartão atualizado no início
            flashCards.insert(updatedCard, at: 0)
            saveFlashCards()
        }
    }
    
    
    func getFlashCard(by id: UUID) -> FlashCard? {
        return flashCards.first { $0.id == id }
    }
    
    func getFlashCards(for anotation: String) -> [FlashCard] {
        return flashCards.filter { $0.anotation == anotation }
    }
    
    func getCategoriaName(for categoriaId: String) -> String? {
        for categoria in CategoriaStore.shared.categorias.values {
            if categoria.id.uuidString == categoriaId {
                return categoria.nome
            }
        }
        return nil
    }
    
    func updateCategoriaName(from oldName: String, to newName: String) {
        flashCards.forEach { flashCard in
            if flashCard.anotation == oldName {
                var updatedCard = flashCard
                updatedCard.anotation = newName
                updateFlashCard(id: flashCard.id, question: flashCard.question, answer: flashCard.answer, anotation: newName)
            }
        }
    }
    
    func updateFlashCard(id: UUID, question: String, answer: String, anotation: String) {
        if let index = flashCards.firstIndex(where: { $0.id == id }) {
            flashCards.remove(at: index)
            let updatedCard = FlashCard(id: id, question: question, answer: answer, anotation: anotation)
            flashCards.insert(updatedCard, at: 0)
            saveFlashCards()
        }
    }
    
}
