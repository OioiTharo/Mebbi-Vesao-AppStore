import UserNotifications
import UIKit
import AVFoundation

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied.")
            }
        }
    }

    func checkAndScheduleNotifications(for reviewDates: [Date]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todaysReviews = reviewDates.filter { date in
            calendar.isDate(calendar.startOfDay(for: date), inSameDayAs: today)
        }
        
        let reviewCount = todaysReviews.count
        
        if reviewCount > 0 {
            let content = UNMutableNotificationContent()
            content.title = "Mebbi"
            content.body = reviewCount == 1 ? "Você tem 1 anotação para revisar hoje!" : "Você tem \(reviewCount) anotações para revisar hoje!"
            content.sound = UNNotificationSound(named: UNNotificationSoundName("flipSound.mp3"))

            var dateComponents = DateComponents()
            dateComponents.hour = 12
            dateComponents.minute = 00

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "daily_review_notification", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
}
