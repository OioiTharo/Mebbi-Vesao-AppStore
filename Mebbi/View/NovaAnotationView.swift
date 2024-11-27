import Foundation
import SwiftUI
import PencilKit
import AVFoundation

extension NSAttributedString {
    func toData() -> Data? {
        do {
            return try self.data(from: NSRange(location: 0, length: self.length),
                                 documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        } catch {
            print("Erro ao converter NSAttributedString para Data: \(error)")
            return nil
        }
    }
    
    static func fromData(_ data: Data) -> NSAttributedString? {
        do {
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.rtf],
                                          documentAttributes: nil)
        } catch {
            print("Erro ao converter Data para NSAttributedString: \(error)")
            return nil
        }
    }
}

struct NovaAnotacaoView: View {
    enum Modo {
        case novo
        case edicao
    }
    
    let modo: Modo
    private var maxCharacters = 30
    private var existingAnotacao: Anotacao?
    @State private var isKeyboardVisible = false
    
    @State private var tituloTemp: String = ""
    @State private var text: String = ""
    @State private var attributedText: NSAttributedString = NSAttributedString(string: "")
    @State private var showingFormatter = false
    @State private var selectedRange: NSRange?
    @Environment(\.presentationMode) var presentationMode
    @State private var mostrarAlerta = false
    @EnvironmentObject var tabBarSettings: TabBarSettings
    @Binding var path: NavigationPath
    @State private var isPresented = true
    
    init(modo: Modo = .novo, anotacao: Anotacao? = nil, path: Binding<NavigationPath>) {
        self.modo = modo
        self.existingAnotacao = anotacao
        self._path = path
        
        if let anotacao = anotacao {
            _tituloTemp = State(initialValue: anotacao.titulo)
            
            // Carregar o texto formatado se existir
            if let formatadoData = anotacao.conteudoFormatado,
               let formatado = NSAttributedString.fromData(formatadoData) {
                _attributedText = State(initialValue: formatado)
                _text = State(initialValue: anotacao.conteudos)
            } else {
                _attributedText = State(initialValue: NSAttributedString(string: anotacao.conteudos))
                _text = State(initialValue: anotacao.conteudos)
            }
        } else {
            _tituloTemp = State(initialValue: "")
            _text = State(initialValue: "")
            _attributedText = State(initialValue: NSAttributedString(string: ""))
        }
    }
    
    private func createInputAccessoryView() -> some View {
        HStack {
            Button("Aa") {
                showingFormatter = true
            }
            .disabled(selectedRange == nil)
            .padding(.horizontal)
            .foregroundColor(.azulPrincipal)
            Spacer()
            
        }
        .frame(height: 44)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.systemGray4))
                .edgesIgnoringSafeArea(.horizontal),
            alignment: .top
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Insira o título", text: $tituloTemp)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.azulPrincipal.opacity(2.5))
                    .padding(.horizontal, 30)
                    .padding(.top)
                    .onChange(of: tituloTemp) { newValue in
                        if newValue.count > maxCharacters {
                            tituloTemp = String(newValue.prefix(maxCharacters))
                        }
                    }
                
                HStack {
                    if tituloTemp.count == maxCharacters {
                        Text("O título atingiu o limite de \(maxCharacters) caracteres.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 30)
                    }
                    if tituloTemp.isEmpty {
                        Text("* O título é obrigatório")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 30)
                    }
                    Spacer()
                }
                
                ZStack(alignment: .topLeading){
                    TextViewRepresentable(
                        text: $text,
                        attributedText: $attributedText,
                        onSelectionChange: { range in
                            selectedRange = range
                        },
                        showFormatting: $showingFormatter,
                        isEditable:true
                    )
                    .padding(.horizontal, 22)
                    .background(Color.background)
                    HStack {
                        if attributedText.string.isEmpty {
                            Text("Insira sua anotação....")
                                .font(.body)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, 30)
                                .padding(.top, 8)
                        }
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .sheet(isPresented: $showingFormatter) {
                Sheetformatacao(onFormatting: { formats in
                    guard let range = selectedRange else { return }
                    let mutableString = NSMutableAttributedString(attributedString: attributedText)
                    let text = mutableString.string as NSString
                    let lineRange = text.lineRange(for: range)
                    let currentLine = text.substring(with: lineRange)
                    
                    mutableString.removeAttribute(.font, range: lineRange)
                    mutableString.removeAttribute(.underlineStyle, range: lineRange)
                    mutableString.removeAttribute(.strikethroughStyle, range: lineRange)
                    mutableString.removeAttribute(.paragraphStyle, range: lineRange)
                    
                    let fontSize: CGFloat = formats.contains(.subtitle) ? 20 : 16
                    let baseFont = UIFont.systemFont(ofSize: fontSize)
                    
                    if formats.contains(.bold) {
                        mutableString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: fontSize), range: lineRange)
                    } else if formats.contains(.italic) {
                        mutableString.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: fontSize), range: lineRange)
                    } else {
                        mutableString.addAttribute(.font, value: baseFont, range: lineRange)
                    }
                    
                    if formats.contains(.underline) {
                        mutableString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: lineRange)
                    }
                    
                    if formats.contains(.strikethrough) {
                        mutableString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: lineRange)
                    }
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = formats.contains(.right) ? .right : .left
                    
                    if formats.contains(.bullet) {
                        if !currentLine.hasPrefix("• ") {
                            let bulletString = "• " + currentLine
                            mutableString.replaceCharacters(in: lineRange, with: bulletString)
                            
                            let newRange = NSRange(location: lineRange.location, length: bulletString.count)
                            mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: newRange)
                        }
                    } else {
                        if currentLine.hasPrefix("• ") {
                            let textWithoutBullet = String(currentLine.dropFirst(2))
                            mutableString.replaceCharacters(in: lineRange, with: textWithoutBullet)
                            
                            let newRange = NSRange(location: lineRange.location, length: textWithoutBullet.count)
                            mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: newRange)
                        } else {
                            mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: lineRange)
                        }
                    }
                    
                    attributedText = mutableString
                })
                .presentationDetents([.height(300)])
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { mostrarAlerta = true }) {
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
                        destination: DetalhesView(
                            modo: modo,
                            titulo: tituloTemp,
                            anotacao: text,
                            conteudoFormatado: attributedText.toData(),
                            existingAnotacao: existingAnotacao,
                            path: $path,
                            isNovaAnotacaoPresented: $isPresented
                        ).navigationBarBackButtonHidden(true)
                    ){
                        HStack {
                            Text("Próxima")
                                .foregroundColor(tituloTemp.isEmpty || text.isEmpty ? .azulPrincipal.opacity(0.5) : .azulPrincipal)
                            Image(systemName: "chevron.forward")
                                .foregroundColor(tituloTemp.isEmpty || text.isEmpty ? .azulPrincipal.opacity(0.5) : .azulPrincipal)
                        }
                    }
                    .disabled(tituloTemp.isEmpty || text.isEmpty)
                }
            }
            .alert(isPresented: $mostrarAlerta) {
                Alert(
                    title: Text("Atenção"),
                    message: Text("Você tem alterações não salvas. Se voltar agora, poderá perder todas as suas edições."),
                    primaryButton: .destructive(Text("Voltar")) {
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text("Cancelar"))
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
        .onChange(of: isPresented) { newValue in
            if !newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NovaAnotacaoView(path: .constant(NavigationPath()))
}
