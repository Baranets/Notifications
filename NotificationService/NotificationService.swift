//
//  NotificationService.swift
//  NotificationService
//
//  Created by Maxim Baranets on 06.02.2020.
//  Copyright © 2020 Maxim Baranets. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent,
            let apsData = bestAttemptContent.userInfo["aps"] as? [String: Any],
            let attachmentURLAsString = apsData["attachment-url"] as? String,
            let attachmentURL = URL(string: attachmentURLAsString)
        else { return }

        downloadImage(from: attachmentURL) { attachment in
            if let attachment = attachment {
                bestAttemptContent.attachments = [attachment]
                contentHandler(bestAttemptContent)
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension NotificationService {
    private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { downloadURL, _, error in
            guard let downloadURL = downloadURL else {
                completion(nil)
                return
            }
            var urlPath = URL(fileURLWithPath: NSTemporaryDirectory())

            let uniqueEndingURL = ProcessInfo.processInfo.globallyUniqueString + ".png"

            urlPath = urlPath.appendingPathComponent(uniqueEndingURL)

            do {
                try FileManager.default.moveItem(at: downloadURL, to: urlPath)
                let attachment = try UNNotificationAttachment(identifier: "notificationIcon", url: urlPath, options: nil)
                completion(attachment)
            } catch let error {
                print(error)
                print(error.localizedDescription)
                completion(nil)
            }
        }

        task.resume()
    }
}
