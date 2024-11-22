import UserNotifications
import UIKit

func solicitarPermissaoNotificacao(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        DispatchQueue.main.async {
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("Permissão para notificações concedida.")
                        UserDefaults.standard.set(true, forKey: "permissaoNotificacoesConcedida")
                    } else {
                        print("Permissão para notificações negada.")
                        UserDefaults.standard.set(false, forKey: "permissaoNotificacoesConcedida")
                    }
                    completion(granted)
                }
            case .authorized:
                print("Permissão para notificações já concedida.")
                completion(true)
            case .denied, .provisional, .ephemeral:
                print("Permissão para notificações negada.")
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }
}
