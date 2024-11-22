import SwiftUI

struct TabButton: View {
    let imageName: String
    let text: String
    let isSelected: Bool
    let isSystemImage: Bool
    let action: () -> Void
    
    init(
        imageName: String,
        text: String,
        isSelected: Bool,
        isSystemImage: Bool = true,
        action: @escaping () -> Void
    ) {
        self.imageName = imageName
        self.text = text
        self.isSelected = isSelected
        self.isSystemImage = isSystemImage
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack {
                if isSystemImage {
                    Image(systemName: imageName)
                        .font(.system(size: 18))
                        .foregroundColor(Color.azulPrincipal)
                        .opacity(isSelected ? 1 : 0.5)
                } else {
                    Image(imageName)
                        .font(.system(size: 20))
                        .opacity(isSelected ? 1 : 0.5)
                }
                
                Text(text)
                    .font(.system(size: 12))
                    .foregroundStyle(isSelected ? Color.azulPrincipal : Color.azulPrincipal.opacity(0.5))
            }
        }
    }
}
