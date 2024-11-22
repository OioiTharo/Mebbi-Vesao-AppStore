import SwiftUI

@main
struct MebbiApp: App {
    @StateObject private var anotacaoManager = AnotacaoManager()
    @StateObject private var tabBarSettings = TabBarSettings()
    @StateObject private var colorSelection: ColorSelection = {
        let cs = ColorSelection()
        cs.corSelecionada = cs.coresRGB.first
        return cs
    }()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    init() {
        let _ = anotacaoManager
        NotificationHandler.shared.checkAndScheduleNotifications(for: [])
    }
    
    var body: some Scene {
        WindowGroup {
            
            if !hasSeenOnboarding {
                TelaDeIntroducao()
                    .environmentObject(tabBarSettings)
                    .environmentObject(anotacaoManager)
            } else {
                TabBarCustom()
                    .environmentObject(tabBarSettings)
                    .environmentObject(anotacaoManager)
                    .appBackground()
            }
        }
    }
}

