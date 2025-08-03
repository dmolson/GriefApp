//
//  MusicPreferencesService.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/3/25.
//

import SwiftUI
import MusicKit

enum SpotifyIntegrationMethod: String, CaseIterable, Codable {
    case app = "Spotify App"
    case web = "Web Browser"
    case automatic = "Automatic"
    
    var description: String {
        switch self {
        case .app: return "Use Spotify app for playback"
        case .web: return "Use web browser for authentication and playback"
        case .automatic: return "Automatically choose best available method"
        }
    }
}

@MainActor
class MusicPreferencesService: ObservableObject {
    @Published var spotifyEnabled = false
    @Published var appleMusicEnabled = false
    @Published var spotifyAuthenticated = false
    @Published var appleMusicAuthenticated = false
    
    // Technical availability (device/app capabilities)
    @Published var spotifyAppInstalled = false
    @Published var spotifyAvailable = true // Always available via web or app
    @Published var appleMusicAvailable = false
    
    // Integration method preferences
    @Published var spotifyIntegrationMethod: SpotifyIntegrationMethod = .automatic
    
    private let userDefaults = UserDefaults.standard
    
    static let shared = MusicPreferencesService()
    
    private init() {
        loadPreferences()
        checkTechnicalAvailability()
    }
    
    // MARK: - Preference Management
    
    private func loadPreferences() {
        spotifyEnabled = userDefaults.bool(forKey: "musicPrefs_spotifyEnabled")
        appleMusicEnabled = userDefaults.bool(forKey: "musicPrefs_appleMusicEnabled")  
        spotifyAuthenticated = userDefaults.bool(forKey: "musicPrefs_spotifyAuthenticated")
        appleMusicAuthenticated = userDefaults.bool(forKey: "musicPrefs_appleMusicAuthenticated")
    }
    
    private func savePreferences() {
        userDefaults.set(spotifyEnabled, forKey: "musicPrefs_spotifyEnabled")
        userDefaults.set(appleMusicEnabled, forKey: "musicPrefs_appleMusicEnabled")
        userDefaults.set(spotifyAuthenticated, forKey: "musicPrefs_spotifyAuthenticated")
        userDefaults.set(appleMusicAuthenticated, forKey: "musicPrefs_appleMusicAuthenticated")
        userDefaults.synchronize()
    }
    
    // MARK: - Technical Availability Check
    
    func checkTechnicalAvailability() {
        // Check if Apple Music is technically available
        appleMusicAvailable = true // MusicKit is available on iOS 15+
        
        // Check if Spotify app is installed
        if let url = URL(string: "spotify:"), UIApplication.shared.canOpenURL(url) {
            spotifyAppInstalled = true
        } else {
            spotifyAppInstalled = false
        }
        
        // Spotify is always available via web or app
        spotifyAvailable = true
        
        // Update integration method based on app availability
        if spotifyIntegrationMethod == .automatic {
            // Don't override user's explicit choice, just update automatic detection
        }
    }
    
    // MARK: - Service Management
    
    func enableSpotify() async -> Bool {
        guard spotifyAvailable else { return false }
        
        // Determine which integration method to use
        let methodToUse = getEffectiveSpotifyMethod()
        
        switch methodToUse {
        case .app:
            return await enableSpotifyApp()
        case .web:
            return await enableSpotifyWeb()
        case .automatic:
            // Try app first, fall back to web
            if spotifyAppInstalled {
                return await enableSpotifyApp()
            } else {
                return await enableSpotifyWeb()
            }
        }
    }
    
    private func enableSpotifyApp() async -> Bool {
        guard spotifyAppInstalled else { return false }
        
        // For app-based integration, simulate authentication
        // In real implementation, this would use Spotify SDK
        spotifyAuthenticated = true
        spotifyEnabled = true
        savePreferences()
        return true
    }
    
    private func enableSpotifyWeb() async -> Bool {
        // For web-based integration, simulate authentication
        // In real implementation, this would open OAuth web flow
        spotifyAuthenticated = true
        spotifyEnabled = true
        savePreferences()
        return true
    }
    
    func getEffectiveSpotifyMethod() -> SpotifyIntegrationMethod {
        switch spotifyIntegrationMethod {
        case .automatic:
            return spotifyAppInstalled ? .app : .web
        case .app, .web:
            return spotifyIntegrationMethod
        }
    }
    
    func enableAppleMusic() async -> Bool {
        guard appleMusicAvailable else { return false }
        
        // Request Apple Music authorization
        let status = await MusicAuthorization.request()
        let authenticated = status == .authorized
        
        appleMusicAuthenticated = authenticated
        appleMusicEnabled = authenticated
        savePreferences()
        return authenticated
    }
    
    func disableSpotify() {
        spotifyEnabled = false
        spotifyAuthenticated = false
        savePreferences()
    }
    
    func disableAppleMusic() {
        appleMusicEnabled = false
        appleMusicAuthenticated = false
        savePreferences()
    }
    
    // MARK: - Query Methods
    
    var enabledServices: [MusicService] {
        var services: [MusicService] = []
        if spotifyEnabled && spotifyAvailable { services.append(.spotify) }
        if appleMusicEnabled && appleMusicAvailable { services.append(.appleMusic) }
        return services
    }
    
    var hasEnabledServices: Bool {
        return !enabledServices.isEmpty
    }
    
    var preferredService: MusicService? {
        // Return the first enabled service, prioritizing Apple Music if both are enabled
        if appleMusicEnabled && appleMusicAvailable { return .appleMusic }
        if spotifyEnabled && spotifyAvailable { return .spotify }
        return nil
    }
    
    func isServiceEnabled(_ service: MusicService) -> Bool {
        switch service {
        case .spotify:
            return spotifyEnabled && spotifyAvailable // spotifyAvailable is always true now
        case .appleMusic:
            return appleMusicEnabled && appleMusicAvailable
        }
    }
    
    func getSpotifyConnectionStatus() -> String {
        if !spotifyEnabled {
            let method = getEffectiveSpotifyMethod()
            switch method {
            case .app:
                return spotifyAppInstalled ? "Connect" : "Install Spotify App"
            case .web:
                return "Connect via Web"
            case .automatic:
                return spotifyAppInstalled ? "Connect" : "Connect via Web"
            }
        } else {
            let method = getEffectiveSpotifyMethod()
            return "Connected (\(method.rawValue))"
        }
    }
    
    func isServiceAuthenticated(_ service: MusicService) -> Bool {
        switch service {
        case .spotify:
            return spotifyAuthenticated && spotifyEnabled
        case .appleMusic:
            return appleMusicAuthenticated && appleMusicEnabled
        }
    }
    
    // MARK: - Reset Functionality
    
    func resetAllPreferences() {
        spotifyEnabled = false
        appleMusicEnabled = false
        spotifyAuthenticated = false
        appleMusicAuthenticated = false
        
        // Clear stored tokens
        userDefaults.removeObject(forKey: "spotifyAccessToken")
        userDefaults.removeObject(forKey: "spotifyRefreshToken")
        userDefaults.removeObject(forKey: "appleMusicToken")
        userDefaults.removeObject(forKey: "musicPlaylists")
        userDefaults.removeObject(forKey: "savedSongs")
        
        savePreferences()
    }
}