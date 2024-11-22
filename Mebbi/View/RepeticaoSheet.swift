import Foundation
import SwiftUI

struct RepeticaoSheet: View {
    var body: some View {
        VStack{
            Text("O que é Repetição Espaçada?")
                .foregroundColor(Color.azulPrincipal)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .font(.title2)
            
            Text("""
            É uma técnica de estudo que otimiza a memorização revisando informações em intervalos crescentes.
            A sequência de números referem-se a intervalos específicos para revisões, por exemplo:
            
            1 - 7 - 30: Revise no 1º dia, 7º dia e 30º dia.
            
            Esses intervalos ajudam a reforçar o aprendizado ao longo do tempo.
            """)
            .foregroundColor(.azulBranco)
            .padding(.horizontal, 30)
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.wg)
    }
}
#Preview {
    RepeticaoSheet()
}
