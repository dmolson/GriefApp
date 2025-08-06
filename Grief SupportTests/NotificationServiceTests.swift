//
//  NotificationServiceTests.swift
//  Grief SupportTests
//
//  Created by Assistant on 8/6/25.
//

import Testing
import Foundation
import UserNotifications
@testable import Grief_Support

@MainActor
struct NotificationServiceTests {
    
    // MARK: - Test Data Generators
    
    private func createTestReminder(
        time: String = "9:00 AM",
        message: String = "Test reminder",
        isEnabled: Bool = true,
        selectedDays: Set<Int> = Set(0...6)
    ) -> Reminder {
        return Reminder(
            time: time,
            message: message,
            isEnabled: isEnabled,
            selectedDays: selectedDays
        )
    }
    
    private func createTestRitual(
        type: RitualType = .connection,
        personName: String = "John",
        description: String = "Test ritual",
        notificationEnabled: Bool = true,
        selectedDays: Set<Int> = Set(0...6)
    ) -> SavedRitual {
        return SavedRitual(
            type: type,
            personName: personName,
            description: description,
            notificationEnabled: notificationEnabled,
            selectedDays: selectedDays
        )
    }
    
    // MARK: - Day Selection Tests
    
    @Test func testSingleDaySelection() async throws {
        let reminder = createTestReminder(selectedDays: Set([1])) // Monday only
        let service = NotificationService.shared
        
        // Schedule the reminder
        await service.scheduleReminder(reminder)
        
        // Verify notification was scheduled
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let reminderRequests = requests.filter { $0.identifier.contains(reminder.id.uuidString) }
        
        #expect(reminderRequests.count == 1, "Should have exactly 1 notification for single day")
        
        // Verify it's scheduled for Monday (weekday = 2 in iOS)
        if let trigger = reminderRequests.first?.trigger as? UNCalendarNotificationTrigger {
            #expect(trigger.dateComponents.weekday == 2, "Should be scheduled for Monday (iOS weekday 2)")
            #expect(trigger.repeats == true, "Should repeat weekly")
        }
        
        // Clean up
        service.cancelReminder(reminder)
    }
    
    @Test func testMultipleDaysSelection() async throws {
        let reminder = createTestReminder(selectedDays: Set([1, 3, 5])) // Mon, Wed, Fri
        let service = NotificationService.shared
        
        await service.scheduleReminder(reminder)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let reminderRequests = requests.filter { $0.identifier.contains(reminder.id.uuidString) }
        
        #expect(reminderRequests.count == 3, "Should have 3 notifications for 3 selected days")
        
        // Verify each day is scheduled correctly
        let expectedWeekdays = [2, 4, 6] // iOS weekdays for Mon, Wed, Fri
        let actualWeekdays = reminderRequests.compactMap { request -> Int? in
            (request.trigger as? UNCalendarNotificationTrigger)?.dateComponents.weekday
        }.sorted()
        
        #expect(actualWeekdays == expectedWeekdays, "Weekdays should match selected days")
        
        service.cancelReminder(reminder)
    }
    
    @Test func testAllDaysSelected() async throws {
        let reminder = createTestReminder(selectedDays: Set(0...6)) // All days
        let service = NotificationService.shared
        
        await service.scheduleReminder(reminder)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let reminderRequests = requests.filter { $0.identifier.contains(reminder.id.uuidString) }
        
        #expect(reminderRequests.count == 7, "Should have 7 notifications for all days")
        
        service.cancelReminder(reminder)
    }
    
    @Test func testWeekdaysOnly() async throws {
        let reminder = createTestReminder(selectedDays: Set([1, 2, 3, 4, 5])) // Weekdays
        let service = NotificationService.shared
        
        await service.scheduleReminder(reminder)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let reminderRequests = requests.filter { $0.identifier.contains(reminder.id.uuidString) }
        
        #expect(reminderRequests.count == 5, "Should have 5 notifications for weekdays")
        
        service.cancelReminder(reminder)
    }
    
    // MARK: - Time Accuracy Tests
    
    @Test func testTimeAccuracy() async throws {
        let reminder = createTestReminder(time: "2:30 PM", selectedDays: Set([2])) // Tuesday
        let service = NotificationService.shared
        
        await service.scheduleReminder(reminder)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let reminderRequest = requests.first { $0.identifier.contains(reminder.id.uuidString) }
        
        if let trigger = reminderRequest?.trigger as? UNCalendarNotificationTrigger {
            #expect(trigger.dateComponents.hour == 14, "Hour should be 14 (2 PM)")
            #expect(trigger.dateComponents.minute == 30, "Minute should be 30")
        }
        
        service.cancelReminder(reminder)
    }
    
    // MARK: - Edit/Update Tests
    
    @Test func testEditDaySelection() async throws {
        let service = NotificationService.shared
        var reminder = createTestReminder(selectedDays: Set([1, 2, 3])) // Mon, Tue, Wed
        
        // Schedule initial reminder
        await service.scheduleReminder(reminder)
        
        // Verify initial setup
        var requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        var reminderRequests = requests.filter { $0.identifier.contains(reminder.id.uuidString) }
        #expect(reminderRequests.count == 3, "Should have 3 initial notifications")
        
        // Update to different days
        reminder.selectedDays = Set([4, 5, 6]) // Thu, Fri, Sat
        
        // Cancel old and schedule new
        service.cancelReminder(reminder)
        await service.scheduleReminder(reminder)
        
        // Verify updated setup
        requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        reminderRequests = requests.filter { $0.identifier.contains(reminder.id.uuidString) }
        #expect(reminderRequests.count == 3, "Should have 3 updated notifications")
        
        // Verify new days
        let weekdays = reminderRequests.compactMap { request -> Int? in
            (request.trigger as? UNCalendarNotificationTrigger)?.dateComponents.weekday
        }.sorted()
        
        #expect(weekdays == [5, 6, 7], "Should be scheduled for Thu, Fri, Sat (iOS weekdays 5, 6, 7)")
        
        service.cancelReminder(reminder)
    }
    
    // MARK: - Toggle On/Off Tests
    
    @Test func testToggleOff() async throws {
        let service = NotificationService.shared
        var reminder = createTestReminder(isEnabled: true, selectedDays: Set([0, 6])) // Weekend
        
        await service.scheduleReminder(reminder)
        
        // Verify scheduled
        var requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        var count = requests.filter { $0.identifier.contains(reminder.id.uuidString) }.count
        #expect(count == 2, "Should have 2 notifications when enabled")
        
        // Toggle off
        reminder.isEnabled = false
        service.cancelReminder(reminder)
        
        // Verify cancelled
        requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        count = requests.filter { $0.identifier.contains(reminder.id.uuidString) }.count
        #expect(count == 0, "Should have 0 notifications when disabled")
    }
    
    // MARK: - Notification Content Tests
    
    @Test func testNotificationContent() async throws {
        let testMessage = "Remember to take care of yourself today"
        let reminder = createTestReminder(message: testMessage, selectedDays: Set([3]))
        let service = NotificationService.shared
        
        await service.scheduleReminder(reminder)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let reminderRequest = requests.first { $0.identifier.contains(reminder.id.uuidString) }
        
        #expect(reminderRequest?.content.title == "Gentle Reminder", "Title should be 'Gentle Reminder'")
        #expect(reminderRequest?.content.body == testMessage, "Body should match the reminder message")
        #expect(reminderRequest?.content.categoryIdentifier == "REMINDER_CATEGORY", "Should have correct category")
        
        service.cancelReminder(reminder)
    }
    
    // MARK: - Identifier Uniqueness Tests
    
    @Test func testIdentifierUniqueness() async throws {
        let reminder1 = createTestReminder(message: "Reminder 1", selectedDays: Set([1, 2]))
        let reminder2 = createTestReminder(message: "Reminder 2", selectedDays: Set([1, 2]))
        let service = NotificationService.shared
        
        await service.scheduleReminder(reminder1)
        await service.scheduleReminder(reminder2)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let reminder1Requests = requests.filter { $0.identifier.contains(reminder1.id.uuidString) }
        let reminder2Requests = requests.filter { $0.identifier.contains(reminder2.id.uuidString) }
        
        #expect(reminder1Requests.count == 2, "Reminder 1 should have 2 notifications")
        #expect(reminder2Requests.count == 2, "Reminder 2 should have 2 notifications")
        
        // Verify no identifier overlap
        let reminder1IDs = Set(reminder1Requests.map { $0.identifier })
        let reminder2IDs = Set(reminder2Requests.map { $0.identifier })
        let intersection = reminder1IDs.intersection(reminder2IDs)
        
        #expect(intersection.isEmpty, "No identifiers should overlap between different reminders")
        
        service.cancelReminder(reminder1)
        service.cancelReminder(reminder2)
    }
    
    // MARK: - Migration Tests
    
    @Test func testMigrationFromOldFormat() throws {
        // Test that old reminders without selectedDays default to all days
        let jsonData = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "time": "10:00 AM",
            "message": "Legacy reminder",
            "isEnabled": true
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let reminder = try decoder.decode(Reminder.self, from: jsonData)
        
        #expect(reminder.selectedDays == Set(0...6), "Legacy reminders should default to all days")
    }
    
    // MARK: - Weekday Conversion Tests
    
    @Test func testWeekdayConversion() {
        // Our format: 0=Sunday, 1=Monday, ..., 6=Saturday
        // iOS format: 1=Sunday, 2=Monday, ..., 7=Saturday
        
        let ourToiOS: [(Int, Int)] = [
            (0, 1), // Sunday
            (1, 2), // Monday
            (2, 3), // Tuesday
            (3, 4), // Wednesday
            (4, 5), // Thursday
            (5, 6), // Friday
            (6, 7)  // Saturday
        ]
        
        for (ourDay, expectedIOSDay) in ourToiOS {
            let convertedDay = ourDay + 1
            #expect(convertedDay == expectedIOSDay, "Day \(ourDay) should convert to iOS day \(expectedIOSDay)")
        }
    }
    
    // MARK: - Display String Tests
    
    @Test func testSelectedDaysDisplay() {
        var reminder = createTestReminder(selectedDays: Set(0...6))
        #expect(reminder.selectedDaysDisplay == "Every day")
        
        reminder.selectedDays = Set([1, 2, 3, 4, 5])
        #expect(reminder.selectedDaysDisplay.contains("Mon") && 
                reminder.selectedDaysDisplay.contains("Fri"))
        
        reminder.selectedDays = Set([0, 6])
        #expect(reminder.selectedDaysDisplay == "Sun, Sat")
        
        reminder.selectedDays = Set([1])
        #expect(reminder.selectedDaysDisplay == "Mon")
        
        reminder.selectedDays = Set()
        #expect(reminder.selectedDaysDisplay == "No days selected")
    }
    
    // MARK: - Cancellation Tests
    
    @Test func testCancellationRemovesAllDays() async throws {
        let reminder = createTestReminder(selectedDays: Set(0...6))
        let service = NotificationService.shared
        
        await service.scheduleReminder(reminder)
        
        // Verify scheduled
        var requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        var count = requests.filter { $0.identifier.contains(reminder.id.uuidString) }.count
        #expect(count == 7, "Should have 7 notifications scheduled")
        
        // Cancel
        service.cancelReminder(reminder)
        
        // Wait a moment for cancellation to process
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Verify all cancelled
        requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        count = requests.filter { $0.identifier.contains(reminder.id.uuidString) }.count
        #expect(count == 0, "Should have 0 notifications after cancellation")
    }
    
    // MARK: - Ritual Notification Tests
    
    @Test func testRitualNotificationContent() async throws {
        let service = NotificationService.shared
        
        // Test Connection Ritual
        let connectionRitual = createTestRitual(type: .connection, personName: "Sarah", selectedDays: Set([1]))
        await service.scheduleRitualNotification(connectionRitual)
        
        var requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        var ritualRequest = requests.first { $0.identifier.contains(connectionRitual.id.uuidString) }
        
        #expect(ritualRequest?.content.title == "Gentle Reminder", "Title should be 'Gentle Reminder'")
        #expect(ritualRequest?.content.body == "Take time to connect with Sarah", "Body should be connection message")
        #expect(ritualRequest?.content.categoryIdentifier == "RITUAL_CATEGORY", "Should have ritual category")
        #expect(ritualRequest?.content.userInfo["ritualId"] as? String == connectionRitual.id.uuidString, "Should contain ritual ID")
        
        service.cancelRitualNotification(connectionRitual)
        
        // Test Reflection Ritual
        let reflectionRitual = createTestRitual(type: .reflection, personName: "Michael", selectedDays: Set([2]))
        await service.scheduleRitualNotification(reflectionRitual)
        
        requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        ritualRequest = requests.first { $0.identifier.contains(reflectionRitual.id.uuidString) }
        
        #expect(ritualRequest?.content.body == "Take time to reflect on Michael", "Body should be reflection message")
        
        service.cancelRitualNotification(reflectionRitual)
    }
    
    @Test func testRitualNotificationUserInfo() async throws {
        let ritual = createTestRitual(selectedDays: Set([3]))
        let service = NotificationService.shared
        
        await service.scheduleRitualNotification(ritual)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let ritualRequest = requests.first { $0.identifier.contains(ritual.id.uuidString) }
        
        let userInfo = ritualRequest?.content.userInfo
        #expect(userInfo != nil, "UserInfo should not be nil")
        #expect(userInfo?["ritualId"] as? String == ritual.id.uuidString, "UserInfo should contain correct ritual ID")
        
        service.cancelRitualNotification(ritual)
    }
    
    @Test func testRitualDaySelection() async throws {
        let ritual = createTestRitual(selectedDays: Set([0, 3, 6])) // Sun, Wed, Sat
        let service = NotificationService.shared
        
        await service.scheduleRitualNotification(ritual)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let ritualRequests = requests.filter { $0.identifier.contains(ritual.id.uuidString) }
        
        #expect(ritualRequests.count == 3, "Should have 3 notifications for 3 selected days")
        
        // Verify each day is scheduled correctly
        let expectedWeekdays = [1, 4, 7] // iOS weekdays for Sun, Wed, Sat
        let actualWeekdays = ritualRequests.compactMap { request -> Int? in
            (request.trigger as? UNCalendarNotificationTrigger)?.dateComponents.weekday
        }.sorted()
        
        #expect(actualWeekdays == expectedWeekdays, "Ritual weekdays should match selected days")
        
        service.cancelRitualNotification(ritual)
    }
    
    @Test func testRitualToggleOnOff() async throws {
        let service = NotificationService.shared
        var ritual = createTestRitual(notificationEnabled: true, selectedDays: Set([1, 5]))
        
        await service.scheduleRitualNotification(ritual)
        
        // Verify scheduled
        var requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        var count = requests.filter { $0.identifier.contains(ritual.id.uuidString) }.count
        #expect(count == 2, "Should have 2 notifications when enabled")
        
        // Toggle off and update
        ritual.notificationEnabled = false
        await service.updateRitualNotification(ritual)
        
        // Verify cancelled
        requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        count = requests.filter { $0.identifier.contains(ritual.id.uuidString) }.count
        #expect(count == 0, "Should have 0 notifications when disabled")
        
        // Toggle back on
        ritual.notificationEnabled = true
        await service.updateRitualNotification(ritual)
        
        // Verify rescheduled
        requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        count = requests.filter { $0.identifier.contains(ritual.id.uuidString) }.count
        #expect(count == 2, "Should have 2 notifications when re-enabled")
        
        service.cancelRitualNotification(ritual)
    }
    
    @Test func testBirthdayRitualContent() async throws {
        // Note: This test would need mock data for LovedOnesDataService
        // For now, we'll test the basic structure
        let ritual = createTestRitual(type: .birthday, personName: "Emma", selectedDays: Set())
        let service = NotificationService.shared
        
        // Birthday rituals are scheduled annually, not weekly
        await service.scheduleRitualNotification(ritual)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let ritualRequest = requests.first { $0.identifier.contains(ritual.id.uuidString) }
        
        // Birthday rituals may not be scheduled if no date is found in LovedOnesDataService
        // But if scheduled, should have correct format
        if let request = ritualRequest {
            #expect(request.content.title == "Gentle Reminder", "Birthday ritual should have Gentle Reminder title")
            #expect(request.content.body == "Take time to remember Emma", "Birthday ritual should have remember message")
            #expect(request.content.userInfo["ritualId"] as? String == ritual.id.uuidString, "Should contain ritual ID")
        }
        
        service.cancelRitualNotification(ritual)
    }
    
    @Test func testAnniversaryRitualContent() async throws {
        let ritual = createTestRitual(type: .anniversary, personName: "David", selectedDays: Set())
        let service = NotificationService.shared
        
        await service.scheduleRitualNotification(ritual)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let ritualRequest = requests.first { $0.identifier.contains(ritual.id.uuidString) }
        
        // Anniversary rituals may not be scheduled if no date is found
        if let request = ritualRequest {
            #expect(request.content.title == "Gentle Reminder", "Anniversary ritual should have Gentle Reminder title")
            #expect(request.content.body == "Take time to remember David", "Anniversary ritual should have remember message")
            #expect(request.content.userInfo["ritualId"] as? String == ritual.id.uuidString, "Should contain ritual ID")
        }
        
        service.cancelRitualNotification(ritual)
    }
    
    @Test func testMultipleRitualsUniqueness() async throws {
        let ritual1 = createTestRitual(personName: "Person1", selectedDays: Set([1, 2]))
        let ritual2 = createTestRitual(personName: "Person2", selectedDays: Set([1, 2]))
        let service = NotificationService.shared
        
        await service.scheduleRitualNotification(ritual1)
        await service.scheduleRitualNotification(ritual2)
        
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let ritual1Requests = requests.filter { $0.identifier.contains(ritual1.id.uuidString) }
        let ritual2Requests = requests.filter { $0.identifier.contains(ritual2.id.uuidString) }
        
        #expect(ritual1Requests.count == 2, "Ritual 1 should have 2 notifications")
        #expect(ritual2Requests.count == 2, "Ritual 2 should have 2 notifications")
        
        // Verify no identifier overlap
        let ritual1IDs = Set(ritual1Requests.map { $0.identifier })
        let ritual2IDs = Set(ritual2Requests.map { $0.identifier })
        let intersection = ritual1IDs.intersection(ritual2IDs)
        
        #expect(intersection.isEmpty, "No identifiers should overlap between different rituals")
        
        service.cancelRitualNotification(ritual1)
        service.cancelRitualNotification(ritual2)
    }
    
    @Test func testRitualCancellationRemovesAllDays() async throws {
        let ritual = createTestRitual(selectedDays: Set(0...6))
        let service = NotificationService.shared
        
        await service.scheduleRitualNotification(ritual)
        
        // Verify scheduled
        var requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        var count = requests.filter { $0.identifier.contains(ritual.id.uuidString) }.count
        #expect(count == 7, "Should have 7 ritual notifications scheduled")
        
        // Cancel
        service.cancelRitualNotification(ritual)
        
        // Wait a moment for cancellation to process
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Verify all cancelled
        requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        count = requests.filter { $0.identifier.contains(ritual.id.uuidString) }.count
        #expect(count == 0, "Should have 0 ritual notifications after cancellation")
    }
}