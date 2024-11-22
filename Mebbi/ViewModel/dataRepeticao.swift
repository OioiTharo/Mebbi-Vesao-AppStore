import Foundation

func calcularDatasFuturas(repeticao: PadraoRepeticao, dataAtual: Date) -> [Date] {
    let calendario = Calendar.current
    var datasFuturas: [Date] = [dataAtual]
    
    let intervalos: [Int]
    switch repeticao {
    case .padrao1:
        intervalos = [1, 7, 30]
    case .padrao2:
        intervalos = [1, 3, 7, 14]
    case .padrao3:
        intervalos = [2, 4, 8, 16, 32]
    case .nenhuma:
        return []
    }
    
    for dias in intervalos {
        if let dataFutura = calendario.date(byAdding: .day, value: dias, to: dataAtual) {
            datasFuturas.append(dataFutura)
        }
    }
    
    return datasFuturas
}

class DataManager: ObservableObject {
    @Published var dataAnotacao = Date.now
    
    func obterDatasFuturas(repeticao: PadraoRepeticao) -> [Date] {
        return calcularDatasFuturas(repeticao: repeticao, dataAtual: dataAnotacao)
    }
}
