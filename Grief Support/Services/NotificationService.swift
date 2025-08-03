//
//  NotificationService.swift
//  Grief Support
//
//  Created by Claude on 8/3/25.
//

import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Permission Management
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    func checkNotificationPermission() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Schedule Reminder Notifications
    
    func scheduleReminder(_ reminder: Reminder) async {
        guard reminder.isEnabled else { return }
        
        // Check permission first
        let status = await checkNotificationPermission()
        guard status == .authorized else {
            print("Notification permission not granted")
            return
        }
        
        // Parse the time string to get hour and minute
        guard let timeComponents = parseTimeString(reminder.time) else {
            print("Failed to parse time: \(reminder.time)")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Gentle Reminder"
        content.body = reminder.message
        content.sound = .default
        content.categoryIdentifier = "REMINDER_CATEGORY"
        
        // Create date components for daily recurring notification
        var dateComponents = DateComponents()
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        // Create trigger for daily repeat
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        // Create notification request
        let request = UNNotificationRequest(
            identifier: "reminder_\(reminder.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Successfully scheduled reminder: \(reminder.message) at \(reminder.time)")
        } catch {
            print("Failed to schedule reminder: \(error)")
        }
    }
    
    func cancelReminder(_ reminder: Reminder) {
        let identifier = "reminder_\(reminder.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled reminder: \(reminder.message)")
    }
    
    func rescheduleAllReminders(_ reminders: [Reminder]) async {
        // Cancel all existing reminder notifications
        await cancelAllReminderNotifications()
        
        // Schedule all enabled reminders
        for reminder in reminders where reminder.isEnabled {
            await scheduleReminder(reminder)
        }
    }
    
    private func cancelAllReminderNotifications() async {
        let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let reminderIdentifiers = pendingRequests
            .map { $0.identifier }
            .filter { $0.hasPrefix("reminder_") }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)
        print("Cancelled \(reminderIdentifiers.count) reminder notifications")
    }
    
    // MARK: - Memorial Date Notifications
    
    func scheduleMemorialReminder(for lovedOne: LovedOne, type: MemorialType) async {
        guard type == .memorial || type == .birthday else { return }
        
        let status = await checkNotificationPermission()
        guard status == .authorized else { return }
        
        // Parse the date string
        guard let date = parseDateString(type == .memorial ? lovedOne.passDate : lovedOne.birthDate) else {
            print("Failed to parse date for \(lovedOne.name)")
            return
        }
        
        let content = UNMutableNotificationContent()
        if type == .memorial {
            content.title = "Remembering \(lovedOne.name)"
            content.body = "Today marks a special day to remember and honor \(lovedOne.name). Take time to cherish their memory."
        } else {
            content.title = "\(lovedOne.name)'s Birthday"
            content.body = "Today would have been \(lovedOne.name)'s birthday. A beautiful day to celebrate their life and the love you shared."
        }
        
        content.sound = .default
        content.categoryIdentifier = "MEMORIAL_CATEGORY"
        
        // Schedule for the anniversary date each year
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.month, .day], from: date)
        dateComponents.hour = 9 // 9 AM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let identifier = "\(type.rawValue)_\(lovedOne.id.uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Scheduled \(type.rawValue) reminder for \(lovedOne.name)")
        } catch {
            print("Failed to schedule \(type.rawValue) reminder: \(error)")
        }
    }
    
    func cancelMemorialReminder(for lovedOne: LovedOne, type: MemorialType) {
        let identifier = "\(type.rawValue)_\(lovedOne.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled \(type.rawValue) reminder for \(lovedOne.name)")
    }
    
    // MARK: - Helper Methods
    
    private func parseTimeString(_ timeString: String) -> (hour: Int, minute: Int)? {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        guard let date = formatter.date(from: timeString) else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return (hour: hour, minute: minute)
    }
    
    private func parseDateString(_ dateString: String) -> Date? {
        let formatters = [
            // Try multiple date formats
            createDateFormatter(format: "MMMM d, yyyy"),  // "March 15, 1985"
            createDateFormatter(format: "MMM d, yyyy"),   // "Mar 15, 1985" 
            createDateFormatter(format: "M/d/yyyy"),      // "3/15/1985"
            createDateFormatter(format: "yyyy-MM-dd")     // "1985-03-15"
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    private func createDateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    // MARK: - Debug Methods
    
    func listPendingNotifications() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        print("=== Pending Notifications (\(requests.count)) ===")
        for request in requests {
            print("ID: \(request.identifier)")
            print("Title: \(request.content.title)")
            print("Body: \(request.content.body)")
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                print("Trigger: \(trigger.dateComponents)")
            }
            print("---")
        }
    }
}

// MARK: - Memorial Type Enum

enum MemorialType: String, CaseIterable {
    case birthday = "birthday"
    case memorial = "memorial"
}

// MARK: - Notification Extensions

extension Reminder {
    var notificationIdentifier: String {
        return "reminder_\(id.uuidString)"
    }
}

extension LovedOne {
    func memorialNotificationIdentifier(type: MemorialType) -> String {
        return "\(type.rawValue)_\(id.uuidString)"
    }
}