import SwiftUI

struct botaoVoltar: View {
    var body: some View {
        HStack{
            Image(systemName: "chevron.backward")
                .foregroundColor(Color.azulPrincipal)
            Text("Voltar")
                .foregroundStyle(Color.azulPrincipal)
        }
    }
}

#Preview {
    botaoVoltar()
}
