import SwiftUI

struct ReadOnlyTextView: UIViewRepresentable {
    let attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.isSelectable = false
        textView.attributedText = attributedText
        textView.backgroundColor = .background
        textView.textColor = .azulPrincipal
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }
}

struct VisualizarAnotacaoView: View {
    let anotacao: Anotacao
    var excluirAnotacao: (Anotacao) -> Void
    @State private var mostrarAlerta = false
    @State private var attributedText: NSAttributedString
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabBarSettings: TabBarSettings
    @Binding var path: NavigationPath
    @State private var isPresented = true
    
    init(anotacao: Anotacao, excluirAnotacao: @escaping (Anotacao) -> Void, path: Binding<NavigationPath>) {
        self.anotacao = anotacao
        self.excluirAnotacao = excluirAnotacao
        self._path = path
        
        if let formatadoData = anotacao.conteudoFormatado,
           let formatado = NSAttributedString.fromData(formatadoData) {
            _attributedText = State(initialValue: formatado)
        } else {
            _attributedText = State(initialValue: NSAttributedString(string: anotacao.conteudos))
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(anotacao.titulo)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.azulPrincipal.opacity(2.5))
                    .padding(.top)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
            
                ReadOnlyTextView(attributedText: attributedText).padding(.horizontal, 20)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        mostrarAlerta.toggle()
                    }) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .frame(width: 80)
                            .foregroundColor(Color.red)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {presentationMode.wrappedValue.dismiss()}){
                        botaoVoltar()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Anotação")
                        .foregroundColor(.azulPrincipal)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: NovaAnotacaoView(
                            modo: .edicao,
                            anotacao: anotacao,
                            path: $path
                        ).navigationBarBackButtonHidden(true)
                    ) {
                        Text("Editar")
                            .foregroundColor(Color.azulPrincipal)
                    }
                }
            }
            .alert(isPresented: $mostrarAlerta) {
                Alert(
                    title: Text("Tem certeza que deseja deletar essa anotação? 🤔"),
                    message: Text("Você pode ter informações importantes nela."),
                    primaryButton: .destructive(Text("Deletar")) {
                        excluirAnotacao(anotacao)
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }.appBackground()
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
}
