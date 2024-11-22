import SwiftUI
import UserNotifications

struct TelaDeIntroducao: View {
    @State private var abaAtual = 0
    @State private var pediuPermissao = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    init() {
        self._pediuPermissao = State(initialValue: UserDefaults.standard.bool(forKey: "permissaoNotificacoesConcedida"))
    }
    
    var body: some View {
        if hasSeenOnboarding {
            ContentView()
        } else {
            TabView(selection: $abaAtual) {
                
                // Tela 1
                VStack {
                    Image("Onboard01")
                        .resizable()
                        .scaledToFill()
                        .frame(height: .infinity)
                }
                .scaledToFill()
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
                .tag(0)
                
                // Tela 2
                VStack {
                    Image("Onboard02")
                        .resizable()
                        .scaledToFill()
                        .frame(height: .infinity)
                }
                .scaledToFill()
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
                .tag(1)
                
                // Tela 3
                VStack {
                    Image("Onboard03")
                        .resizable()
                        .scaledToFill()
                        .frame(height: .infinity)
                }
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
                .tag(2)
                
                // Tela 4
                ZStack {
                    Image("Onboard04")
                        .resizable()
                        .scaledToFill()
                        .frame(height: .infinity)
                  
                    Color.clear.onAppear {
                        if !pediuPermissao {
                            solicitarPermissaoNotificacao { granted in
                                UserDefaults.standard.set(granted, forKey: "permissaoNotificacoesConcedida")
                                pediuPermissao = true
                                hasSeenOnboarding = true
                            }
                        }
                    }
                    
                    
                }
                .scaledToFill()
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            .ignoresSafeArea()
        }
    }
}

struct TelaDeIntroducao_Previews: PreviewProvider {
    static var previews: some View {
        TelaDeIntroducao()
    }
}
