//
//  NotificationService.swift
//  Grief Support
//
//  Created by Claude on 8/3/25.
//

import Foundation
import UserNotifications

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    // Lock for thread-safe notification operations
    private let notificationLock = NSLock()
    
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
        
        // Schedule a notification for each selected day
        for dayIndex in reminder.selectedDays {
            // Convert our day index (0=Sunday) to iOS weekday (1=Sunday)
            let iOSWeekday = dayIndex + 1
            
            // Create date components for specific day and time
            var dateComponents = DateComponents()
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            dateComponents.weekday = iOSWeekday
            
            // Create trigger for weekly repeat on this day
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )
            
            // Create notification request with unique identifier for this day
            let request = UNNotificationRequest(
                identifier: "reminder_\(reminder.id.uuidString)_\(dayIndex)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("Successfully scheduled reminder for day \(dayIndex): \(reminder.message) at \(reminder.time)")
            } catch {
                print("Failed to schedule reminder for day \(dayIndex): \(error)")
            }
        }
    }
    
    func cancelReminder(_ reminder: Reminder) {
        // Cancel all notifications for this reminder (one for each day)
        var identifiers: [String] = []
        
        // Add identifiers for each possible day (0-6)
        for dayIndex in 0...6 {
            identifiers.append("reminder_\(reminder.id.uuidString)_\(dayIndex)")
        }
        
        // Also include the old format identifier for backward compatibility
        identifiers.append("reminder_\(reminder.id.uuidString)")
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Cancelled reminder notifications: \(reminder.message)")
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
    
    // MARK: - Ritual Notifications
    
    func scheduleRitualNotification(_ ritual: SavedRitual) async {
        guard ritual.notificationEnabled else { return }
        
        // Check permission first
        let status = await checkNotificationPermission()
        guard status == .authorized else {
            print("Notification permission not granted for ritual")
            return
        }
        
        // Handle Birthday and Anniversary rituals differently
        if ritual.type == .birthday || ritual.type == .anniversary {
            await scheduleAnnualRitualNotification(ritual)
            return
        }
        
        // Create notification content for regular rituals
        let content = UNMutableNotificationContent()
        content.title = "Gentle Reminder"
        
        // Create appropriate body text based on ritual type
        var bodyText: String
        switch ritual.type {
        case .connection:
            bodyText = "Take time to connect with \(ritual.personName)"
        case .reflection:
            bodyText = "Take time to reflect"
        default:
            bodyText = "Time for \(ritual.personName)'s \(ritual.type.rawValue.lowercased())"
        }
        
        content.body = bodyText
        content.sound = .default
        content.categoryIdentifier = "RITUAL_CATEGORY"
        
        // Add ritual ID to userInfo for deep linking
        content.userInfo = ["ritualId": ritual.id.uuidString]
        
        // Get hour and minute from ritual notification time
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: ritual.notificationTime)
        
        // Schedule a notification for each selected day
        for dayIndex in ritual.selectedDays {
            // Convert our day index (0=Sunday) to iOS weekday (1=Sunday)
            let iOSWeekday = dayIndex + 1
            
            // Create date components for specific day and time
            var dateComponents = DateComponents()
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            dateComponents.weekday = iOSWeekday
            
            // Create trigger for weekly repeat on this day
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )
            
            // Create notification request with unique identifier for this day
            let request = UNNotificationRequest(
                identifier: "ritual_\(ritual.id.uuidString)_\(dayIndex)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("Successfully scheduled ritual notification for day \(dayIndex): \(ritual.name) at \(ritual.notificationTime)")
            } catch {
                print("Failed to schedule ritual notification for day \(dayIndex): \(error)")
            }
        }
    }
    
    private func scheduleAnnualRitualNotification(_ ritual: SavedRitual) async {
        // Get the loved one's birth or pass date
        let lovedOnesService = LovedOnesDataService.shared
        let dateString: String?
        
        if ritual.type == .birthday {
            dateString = lovedOnesService.getBirthDate(for: ritual.personName)
        } else if ritual.type == .anniversary {
            dateString = lovedOnesService.getPassDate(for: ritual.personName)
        } else {
            return // Should not happen
        }
        
        guard let dateStr = dateString,
              let date = parseDateString(dateStr) else {
            print("Failed to parse date for \(ritual.personName)'s \(ritual.type.rawValue) ritual")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Gentle Reminder"
        
        // Use consistent messaging for birthday and anniversary
        content.body = "Take time to remember \(ritual.personName)"
        
        content.sound = .default
        content.categoryIdentifier = "RITUAL_CATEGORY"
        
        // Add ritual ID to userInfo for deep linking
        content.userInfo = ["ritualId": ritual.id.uuidString]
        
        // Get hour and minute from ritual notification time
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: ritual.notificationTime)
        
        // Schedule for the anniversary date each year
        var dateComponents = calendar.dateComponents([.month, .day], from: date)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        // Use a special identifier for annual rituals
        let identifier = "ritual_annual_\(ritual.id.uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Successfully scheduled annual \(ritual.type.rawValue) ritual for \(ritual.personName)")
        } catch {
            print("Failed to schedule annual ritual: \(error)")
        }
    }
    
    func cancelRitualNotification(_ ritual: SavedRitual) {
        // Cancel all notifications for this ritual
        var identifiers: [String] = []
        
        // For Birthday and Anniversary rituals, use the annual identifier
        if ritual.type == .birthday || ritual.type == .anniversary {
            identifiers.append("ritual_annual_\(ritual.id.uuidString)")
        } else {
            // Add identifiers for each possible day (0-6) for regular rituals
            for dayIndex in 0...6 {
                identifiers.append("ritual_\(ritual.id.uuidString)_\(dayIndex)")
            }
        }
        
        // Also include the old format identifier for backward compatibility
        identifiers.append("ritual_\(ritual.id.uuidString)")
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Cancelled ritual notifications: \(ritual.name)")
    }
    
    func updateRitualNotification(_ ritual: SavedRitual) async {
        // Cancel existing notification
        cancelRitualNotification(ritual)
        
        // Schedule new one if enabled
        if ritual.notificationEnabled {
            await scheduleRitualNotification(ritual)
        }
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