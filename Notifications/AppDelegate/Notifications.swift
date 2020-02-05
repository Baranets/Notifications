//
//  Notifications.swift
//  Notification
//
//  Created by Maxim Baranets on 06.02.2020.
//  Copyright © 2020 Maxim Baranets. All rights reserved.
//

import UIKit
import UserNotifications

class Notifications: NSObject {
    let notificationCenter: UNUserNotificationCenter

    override init() {
        notificationCenter = UNUserNotificationCenter.current()
        super.init()
        notificationCenter.delegate = self
    }

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                self.getNotificationSettings()
            }
        }
    }

    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { settings in
            print(settings)
        }
    }

    func scheduleNotification(notificationType: String) {
        let content = UNMutableNotificationContent()
        let userAction = "User Action"

        content.title = notificationType
        content.body = "This is exmaple how to create \(notificationType)"
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = userAction
        
        if let path = Bundle.main.path(forResource: "notificationIcon", ofType: "png")  {
            let url = URL(fileURLWithPath: path)
            do {
                let attachment = try UNNotificationAttachment(
                    identifier: "notificationIcon",
                    url: url,
                    options: nil
                )
                
                content.attachments = [attachment]
            } catch let error {
                print(error)
                print(error.localizedDescription)
            }
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print(error)
                print(error.localizedDescription)
            }
        }

        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])

        let category = UNNotificationCategory(
            identifier: userAction,
            actions: [snoozeAction, deleteAction],
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([category])
    }
}

extension Notifications: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.notification.request.identifier {
        case "Local Notification":
            print("Handling Local Notification")
        default:
            break
        }

        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("dissmiss")
        case UNNotificationDefaultActionIdentifier:
            print("default")
        case "Snooze":
            print("snooze")
            scheduleNotification(notificationType: response.notification.request.content.title)
        case "Delete":
            print("delete")
        default:
            print("Unknown")
        }
        completionHandler()
    }
}
