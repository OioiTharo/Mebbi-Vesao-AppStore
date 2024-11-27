import SwiftUI
import UIKit

enum FormatType {
    case subtitle, body
    case bold, italic, underline, strikethrough
    case bullet
    case right
}

struct TextViewRepresentable: UIViewRepresentable {
    @Binding var text: String
    @Binding var attributedText: NSAttributedString
    var onSelectionChange: (NSRange?) -> Void
    @Binding var showFormatting: Bool
    var isEditable: Bool = false
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .background
        textView.textColor = .azulPrincipal
        textView.isEditable = true
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        
        DispatchQueue.main.async {
            if let parentView = textView.superview?.superview {
                let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.dismissKeyboard))
                tapGesture.cancelsTouchesInView = false
                parentView.addGestureRecognizer(tapGesture)
            }
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let formatButton = UIBarButtonItem(title: "Aa", style: .plain, target: context.coordinator, action: #selector(Coordinator.formatButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [formatButton, flexSpace]
        textView.inputAccessoryView = toolbar
        
        if attributedText.length > 0 {
            textView.attributedText = attributedText
        } else {
            textView.text = text
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.attributedText != attributedText {
            let selectedRange = uiView.selectedRange
            uiView.attributedText = attributedText
            uiView.selectedRange = selectedRange
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewRepresentable
        private var lastSelectedRange: NSRange?
        
        init(_ parent: TextViewRepresentable) {
            self.parent = parent
        }
        
        @objc func formatButtonTapped() {
            parent.showFormatting = true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if let selectedRange = textView.selectedRange as? NSRange {
                let mutableAttrText = NSMutableAttributedString(attributedString: textView.attributedText)
                
                if selectedRange.length > 0 {
                    let currentAttributes = textView.attributedText.attributes(at: selectedRange.location, effectiveRange: nil)
                    mutableAttrText.addAttributes(currentAttributes, range: selectedRange)
                }
                
                textView.attributedText = mutableAttrText
            }
            
            parent.text = textView.text
            parent.attributedText = textView.attributedText
            lastSelectedRange = textView.selectedRange
            parent.onSelectionChange(lastSelectedRange)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            lastSelectedRange = textView.selectedRange
            parent.onSelectionChange(textView.selectedRange)
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard text == "\n",
                  let attributedText = textView.attributedText else { return true }
            
            let nsString = attributedText.string as NSString
            let lineRange = nsString.lineRange(for: range)
            let currentLine = nsString.substring(with: lineRange)
            
            if currentLine.hasPrefix("• ") {
                if currentLine.trimmingCharacters(in: CharacterSet.whitespaces) == "•" {
                    let mutableAttrText = NSMutableAttributedString(attributedString: attributedText)
                    let newLineAttr = NSAttributedString(string: "\n")
                    mutableAttrText.replaceCharacters(in: lineRange, with: newLineAttr.string)
                    textView.attributedText = mutableAttrText
                    textView.selectedRange = NSRange(location: range.location + 1, length: 0)
                } else {
                    let mutableAttrText = NSMutableAttributedString(attributedString: attributedText)
                    
                    let attributes = attributedText.attributes(at: lineRange.location, effectiveRange: nil)
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    if let currentStyle = attributes[.paragraphStyle] as? NSParagraphStyle {
                        paragraphStyle.setParagraphStyle(currentStyle)
                    }
                    
                    var newAttributes = attributes
                    newAttributes[.paragraphStyle] = paragraphStyle
                    
                    let newLineWithBullet = "\n• "
                    let bulletAttr = NSAttributedString(string: newLineWithBullet, attributes: newAttributes)
                    mutableAttrText.insert(bulletAttr, at: range.location)
                    
                    textView.attributedText = mutableAttrText
                    textView.selectedRange = NSRange(location: range.location + newLineWithBullet.count, length: 0)
                }
                
                parent.text = textView.text
                parent.attributedText = textView.attributedText
                return false
            }
            
            return true
        }
        @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
            if let view = sender.view?.subviews.first(where: { $0 is UITextView }) as? UITextView {
                if !view.bounds.contains(sender.location(in: view)) {
                    view.endEditing(true)
                }
            }
        }
    }
}

struct FormatButton: View {
    let type: FormatType
    let isActive: Bool
    let action: () -> Void
    
    @ViewBuilder
    var content: some View {
        switch type {
        case .subtitle:
            Text("Subtítulo")
                .font(.headline)
                .padding(.horizontal)
                .background(isActive ? .azulPrincipal : Color.clear)
        case .body:
            Text("Corpo")
                .font(.body)
                .padding(.horizontal)
                .background(isActive ? .azulPrincipal : Color.clear)
        case .bold: Text("B").bold()
        case .italic: Text("I").italic()
        case .underline: Text("U").underline()
        case .strikethrough: Text("S").strikethrough()
        case .bullet: Image(systemName: "list.bullet")
        case .right: Image(systemName: "arrow.right.to.line")
        }
    }
    
    var body: some View {
        Button(action: action) {
            content
                .foregroundColor(isActive ? .white : Color.wb)
                .frame(width: type == .subtitle || type == .body ? nil : 70,
                       height: type == .subtitle || type == .body ? nil : 50)
                .background(type == .subtitle || type == .body ? nil :
                                isActive ? .azulPrincipal : Color.cinza.opacity(0.2))
                .cornerRadius(8)
        }
    }
}

struct Sheetformatacao: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activeFormats: Set<FormatType> = [.body]
    var onFormatting: (Set<FormatType>) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Formatar")
                    .font(.title)
                    .bold()
                    .padding(.horizontal)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                FormatButton(type: .subtitle,
                             isActive: activeFormats.contains(.subtitle)) {
                    updateFormat(.subtitle, excludes: [.body])
                }
                FormatButton(type: .body,
                             isActive: activeFormats.contains(.body)) {
                    updateFormat(.body, excludes: [.subtitle])
                }
                Spacer()
            }.padding(.vertical, 5).padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                FormatButton(type: .bold,
                             isActive: activeFormats.contains(.bold)) {
                    updateFormat(.bold, excludes: [])
                }
                
                FormatButton(type: .italic,
                             isActive: activeFormats.contains(.italic)) {
                    updateFormat(.italic, excludes: [])
                }
                
                FormatButton(type: .underline,
                             isActive: activeFormats.contains(.underline)) {
                    updateFormat(.underline, excludes: [])
                }
                
                FormatButton(type: .strikethrough,
                             isActive: activeFormats.contains(.strikethrough)) {
                    updateFormat(.strikethrough, excludes: [])
                }
                
                FormatButton(type: .bullet,
                             isActive: activeFormats.contains(.bullet)) {
                    updateFormat(.bullet, excludes: [])
                }
                
                FormatButton(type: .right,
                             isActive: activeFormats.contains(.right)) {
                    updateFormat(.right, excludes: [])
                }
            }
            .padding()
            
        }.padding(.horizontal)
    }
    
    private func updateFormat(_ format: FormatType, excludes: [FormatType]) {
        switch format {
        case .subtitle:
            if activeFormats.contains(.subtitle) {
                activeFormats.remove(.subtitle)
                activeFormats.insert(.body)
            } else {
                activeFormats.insert(.subtitle)
                activeFormats.remove(.body)
            }
            
        case .body:
            if activeFormats.contains(.body) {
                activeFormats.remove(.body)
                activeFormats.insert(.subtitle)
            } else {
                activeFormats.insert(.body)
                activeFormats.remove(.subtitle)
            }
            
        case .right:
            if activeFormats.contains(.right) {
                activeFormats.remove(.right)
            } else {
                activeFormats.insert(.right)
            }
            
        case .bullet:
            if activeFormats.contains(.bullet) {
                activeFormats.remove(.bullet)
            } else {
                activeFormats.insert(.bullet)
            }
            
        default:
            if activeFormats.contains(format) {
                activeFormats.remove(format)
            } else {
                activeFormats.insert(format)
                if format == .bold {
                    activeFormats.remove(.italic)
                } else if format == .italic {
                    activeFormats.remove(.bold)
                }
            }
        }
        
        onFormatting(activeFormats)
    }
}
