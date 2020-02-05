//
//  ViewController.swift
//  Notification
//
//  Created by Maxim Baranets on 05.02.2020.
//  Copyright © 2020 Maxim Baranets. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {
    let cellTexts = [
        "Local Notification",
        "Local Notification with Action",
        "Local Notification with Content",
        "Push Notification with APNs",
        "Push Notification with Firebase",
        "Push Notification with Content",
    ]

    let notifications = Notifications()

    var alert: UIAlertController {
        let alert = UIAlertController(title: "Notification", message: "You will see the notification after 5 sec", preferredStyle: .alert)
        let okButoon = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okButoon)
        return alert
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let footerView = UIView()
        if #available(iOS 13.0, *) {
            footerView.backgroundColor = .systemBackground
        } else {
            footerView.backgroundColor = .white
        }
        tableView.tableFooterView = footerView
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTexts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        cell.textLabel?.text = cellTexts[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        present(alert, animated: true)
        switch indexPath.row {
        case 0:
            notifications.scheduleNotification(notificationType: "Local Notification")
        default:
            break
        }
    }
}
