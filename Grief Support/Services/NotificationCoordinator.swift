//
//  NotificationCoordinator.swift
//  Grief Support
//
//  Created by Claude on 8/6/25.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationCoordinator: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationCoordinator()
    
    // Published properties for navigation
    @Published var selectedTab: Int = 0
    @Published var ritualIdToOpen: String? = nil
    @Published var shouldNavigateToRitual: Bool = false
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Called when user taps on a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Check if this is a ritual notification
        if let ritualId = userInfo["ritualId"] as? String {
            // Navigate to Rituals tab and open the specific ritual
            DispatchQueue.main.async {
                self.selectedTab = 2 // Rituals tab
                self.ritualIdToOpen = ritualId
                self.shouldNavigateToRitual = true
            }
        }
        
        completionHandler()
    }
    
    // Called when a notification is about to be presented while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play sound even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: - Helper Methods
    
    func resetNavigation() {
        ritualIdToOpen = nil
        shouldNavigateToRitual = false
    }
}