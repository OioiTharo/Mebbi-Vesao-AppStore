import SwiftUI

struct barraDePesquisa: View {
    @Binding var textoPesquisa: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("lilas")) 
                .frame(height: 40)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .font(.title3)

                TextField("", text: $textoPesquisa)
                    .foregroundColor(.white)
                    .placeholder(when: textoPesquisa.isEmpty) {
                            Text("Título da anotação...")
                                .foregroundColor(.white)
                    }

                Spacer()
            }
            .padding(.horizontal, 10)
        }
        .padding(.horizontal)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
