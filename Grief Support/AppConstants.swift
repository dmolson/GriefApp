//
//  AppConstants.swift
//  Grief Support
//
//  Created by Claude on 8/3/25.
//

import Foundation

enum AppConstants {
    // MARK: - App Information
    static let appName = "Light After Loss"
    static let appBundleIdentifier = "com.soulfulai.afterlight"
    
    // MARK: - Support
    static let supportEmail = "wearesoulfulai@gmail.com"
    static let supportEmailSubject = "Light After Loss - Support Request"
    
    // MARK: - URLs
    enum URLs {
        static let crisisHotline = "tel://988"
        static let griefShareWebsite = "https://www.griefshare.org"
        static let psychologyTodayTherapists = "https://www.psychologytoday.com/us/therapists/grief"
        static let samhsaWebsite = "https://www.samhsa.gov"
        static let hospiceFoundation = "https://hospicefoundation.org"
        static let griefRecoveryWebsite = "https://www.griefrecoverymethod.com"
        static let centerForLoss = "https://www.centerforloss.com"
        static let childrenGriefSupport = "https://www.dougy.org"
        static let grievingDotCom = "https://www.grieving.com"
        static let bereavementSupport = "https://www.bereavement.co.uk"
    }
    
    // MARK: - Privacy
    static let privacyPolicyVersion = "1.0"
    static let lastPrivacyPolicyUpdate = "January 2025"
    
    // MARK: - Notifications
    enum NotificationIdentifiers {
        static let reminderCategory = "REMINDER_CATEGORY"
        static let memorialCategory = "MEMORIAL_CATEGORY"
        static let reminderPrefix = "reminder_"
        static let memorialPrefix = "memorial_"
    }
    
    // MARK: - Storage Keys
    enum StorageKeys {
        static let savedRituals = "savedRituals"
        static let savedLovedOnes = "savedLovedOnes"
        static let reminders = "reminders"
        static let isDarkMode = "isDarkMode"
        static let useSystemTheme = "useSystemTheme"
        static let musicServiceKey = "selectedMusicService"
        static let lastBackupDate = "lastBackupDate"
    }
    
    // MARK: - UI Constants
    enum UI {
        static let maxPhotoCount = 5
        static let quoteRotationInterval: TimeInterval = 4.0
        static let animationDuration: TimeInterval = 0.25
        static let shareSheetDelay: UInt64 = 200_000_000 // nanoseconds
    }
}