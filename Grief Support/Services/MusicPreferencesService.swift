//
//  MusicPreferencesService.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/3/25.
//

import SwiftUI
import MusicKit

@MainActor
class MusicPreferencesService: ObservableObject {
    @Published var spotifyEnabled = false
    @Published var appleMusicEnabled = false
    @Published var spotifyAuthenticated = false
    @Published var appleMusicAuthenticated = false
    
    // Technical availability (device/app capabilities)
    @Published var spotifyAvailable = false
    @Published var appleMusicAvailable = false
    
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
            spotifyAvailable = true
        } else {
            spotifyAvailable = false
            // If Spotify becomes unavailable, disable it
            if spotifyEnabled && !spotifyAvailable {
                spotifyEnabled = false
                spotifyAuthenticated = false
                savePreferences()
            }
        }
    }
    
    // MARK: - Service Management
    
    func enableSpotify() async -> Bool {
        guard spotifyAvailable else { return false }
        
        // In a real implementation, this would handle Spotify OAuth
        // For now, simulate authentication
        spotifyAuthenticated = true
        spotifyEnabled = true
        savePreferences()
        return true
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
            return spotifyEnabled && spotifyAvailable
        case .appleMusic:
            return appleMusicEnabled && appleMusicAvailable
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