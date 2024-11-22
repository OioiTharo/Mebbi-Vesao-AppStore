import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        if hasSeenOnboarding {
            ContentView()
        } else {
            TelaDeIntroducao()
        }
    }
}

#Preview {
    RootView()
}
