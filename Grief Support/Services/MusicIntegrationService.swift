//
//  MusicIntegrationService.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/3/25.
//

import SwiftUI
import MusicKit

enum MusicService: String, CaseIterable, Codable {
    case appleMusic = "Apple Music"
    case spotify = "Spotify"
    
    var icon: String {
        switch self {
        case .appleMusic: return "music.note"
        case .spotify: return "music.note.list"
        }
    }
    
    var color: Color {
        switch self {
        case .appleMusic: return .red
        case .spotify: return .green
        }
    }
}

struct MusicSelection: Codable, Identifiable {
    let id = UUID()
    var service: MusicService
    var title: String
    var artist: String
    var spotifyID: String?
    var appleMusicID: String?
    var isPlaylist: Bool
    
    init(service: MusicService, title: String, artist: String = "", spotifyID: String? = nil, appleMusicID: String? = nil, isPlaylist: Bool = false) {
        self.service = service
        self.title = title
        self.artist = artist
        self.spotifyID = spotifyID
        self.appleMusicID = appleMusicID
        self.isPlaylist = isPlaylist
    }
}

@MainActor
class MusicIntegrationService: ObservableObject {
    @Published var searchResults: [MusicSelection] = []
    @Published var isSearching = false
    
    private let preferencesService = MusicPreferencesService.shared
    
    init() {
        // Preferences service handles availability checking
    }
    
    // MARK: - Convenience Properties
    var appleMusicAvailable: Bool {
        return preferencesService.isServiceEnabled(.appleMusic)
    }
    
    var spotifyAvailable: Bool {
        return preferencesService.isServiceEnabled(.spotify)
    }
    
    var enabledServices: [MusicService] {
        return preferencesService.enabledServices
    }
    
    // MARK: - Apple Music Integration
    func requestAppleMusicPermission() async -> Bool {
        return await preferencesService.enableAppleMusic()
    }
    
    func searchAppleMusic(query: String) async -> [MusicSelection] {
        guard preferencesService.isServiceEnabled(.appleMusic) else { return [] }
        
        let status = await MusicAuthorization.request()
        guard status == .authorized else { return [] }
        
        do {
            var searchRequest = MusicCatalogSearchRequest(term: query, types: [Song.self, Playlist.self])
            searchRequest.limit = 10
            
            let searchResponse = try await searchRequest.response()
            var results: [MusicSelection] = []
            
            // Add songs
            for song in searchResponse.songs {
                let selection = MusicSelection(
                    service: .appleMusic,
                    title: song.title,
                    artist: song.artistName,
                    appleMusicID: song.id.rawValue,
                    isPlaylist: false
                )
                results.append(selection)
            }
            
            // Add playlists
            for playlist in searchResponse.playlists {
                let selection = MusicSelection(
                    service: .appleMusic,
                    title: playlist.name,
                    artist: playlist.curatorName ?? "Apple Music",
                    appleMusicID: playlist.id.rawValue,
                    isPlaylist: true
                )
                results.append(selection)
            }
            
            return results
        } catch {
            print("Apple Music search error: \(error)")
            return []
        }
    }
    
    func playAppleMusicSelection(_ selection: MusicSelection) async -> Bool {
        guard let appleMusicID = selection.appleMusicID else { return false }
        
        do {
            let player = ApplicationMusicPlayer.shared
            
            if selection.isPlaylist {
                if let playlist = try await MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: MusicItemID(appleMusicID)).response().items.first {
                    let playlistTracks = try await playlist.with(.tracks)
                    if let tracks = playlistTracks.tracks {
                        player.queue = ApplicationMusicPlayer.Queue(for: tracks)
                    }
                }
            } else {
                if let song = try await MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(appleMusicID)).response().items.first {
                    player.queue = ApplicationMusicPlayer.Queue(for: [song])
                }
            }
            
            try await player.play()
            return true
        } catch {
            print("Apple Music playback error: \(error)")
            return false
        }
    }
    
    // MARK: - Spotify Integration
    func searchSpotify(query: String) async -> [MusicSelection] {
        // Note: This would require Spotify Web API implementation
        // For now, return mock results that can deep link to Spotify
        guard preferencesService.isServiceEnabled(.spotify) else { return [] }
        
        // Mock search results - in real implementation, this would call Spotify Web API
        return [
            MusicSelection(
                service: .spotify,
                title: "Search on Spotify",
                artist: "Tap to open Spotify and search",
                spotifyID: nil,
                isPlaylist: false
            )
        ]
    }
    
    func openSpotifySearch(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        if let url = URL(string: "spotify:search:\(encodedQuery)") {
            UIApplication.shared.open(url)
        }
    }
    
    func playSpotifySelection(_ selection: MusicSelection) -> Bool {
        guard let spotifyID = selection.spotifyID else {
            // If no specific ID, open Spotify search
            openSpotifySearch(query: selection.title)
            return true
        }
        
        let urlString = selection.isPlaylist ? "spotify:playlist:\(spotifyID)" : "spotify:track:\(spotifyID)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
            return true
        }
        
        return false
    }
    
    // MARK: - Universal Search
    func searchMusic(query: String, service: MusicService? = nil) async {
        guard !query.isEmpty else { return }
        guard preferencesService.hasEnabledServices else { return }
        
        isSearching = true
        searchResults = []
        
        var results: [MusicSelection] = []
        
        // Only search enabled services
        if (service == nil || service == .appleMusic) && preferencesService.isServiceEnabled(.appleMusic) {
            let appleResults = await searchAppleMusic(query: query)
            results.append(contentsOf: appleResults)
        }
        
        if (service == nil || service == .spotify) && preferencesService.isServiceEnabled(.spotify) {
            let spotifyResults = await searchSpotify(query: query)
            results.append(contentsOf: spotifyResults)
        }
        
        searchResults = results
        isSearching = false
    }
    
    // MARK: - Playback
    func playMusicSelection(_ selection: MusicSelection) async -> Bool {
        switch selection.service {
        case .appleMusic:
            return await playAppleMusicSelection(selection)
        case .spotify:
            return playSpotifySelection(selection)
        }
    }
}