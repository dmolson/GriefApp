//
//  MusicSearchView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/3/25.
//

import SwiftUI

struct MusicSearchView: View {
    @ObservedObject var musicService: MusicIntegrationService
    let onMusicSelected: (MusicSelection) -> Void
    
    @State private var searchQuery = ""
    @State private var selectedService: MusicService? = nil
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Service Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose Music Service")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        if musicService.appleMusicAvailable {
                            MusicServiceButton(
                                service: .appleMusic,
                                isSelected: selectedService == .appleMusic,
                                onSelect: { selectedService = .appleMusic }
                            )
                        }
                        
                        if musicService.spotifyAvailable {
                            MusicServiceButton(
                                service: .spotify,
                                isSelected: selectedService == .spotify,
                                onSelect: { selectedService = .spotify }
                            )
                        }
                        
                        if !musicService.spotifyAvailable && !musicService.appleMusicAvailable {
                            Text("No music services available")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                
                // Search Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Search for Song or Playlist")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack {
                        TextField("Enter song title, artist, or playlist name", text: $searchQuery)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: performSearch) {
                            Image(systemName: musicService.isSearching ? "stop.circle" : "magnifyingglass")
                                .foregroundColor(ThemeColors.adaptivePrimary)
                        }
                        .disabled(searchQuery.isEmpty)
                    }
                }
                .padding(.horizontal)
                
                // Search Results
                if musicService.isSearching {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Searching...")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if !musicService.searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(musicService.searchResults) { result in
                                MusicResultRow(
                                    selection: result,
                                    onSelect: {
                                        onMusicSelected(result)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if !searchQuery.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        
                        Text("No results found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Try searching with different keywords")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Add Music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Auto-select first available service
            if musicService.appleMusicAvailable && selectedService == nil {
                selectedService = .appleMusic
            } else if musicService.spotifyAvailable && selectedService == nil {
                selectedService = .spotify
            }
        }
    }
    
    private func performSearch() {
        guard !searchQuery.isEmpty else { return }
        
        Task {
            await musicService.searchMusic(query: searchQuery, service: selectedService)
        }
    }
}

struct MusicServiceButton: View {
    let service: MusicService
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                Image(systemName: service.icon)
                    .foregroundColor(isSelected ? .white : service.color)
                
                Text(service.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? service.color : Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MusicResultRow: View {
    let selection: MusicSelection
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: selection.isPlaylist ? "music.note.list" : "music.note")
                    .font(.system(size: 20))
                    .foregroundColor(selection.service.color)
                    .frame(width: 40, height: 40)
                    .background(selection.service.color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(selection.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !selection.artist.isEmpty {
                        Text(selection.artist)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: selection.service.icon)
                            .font(.system(size: 10))
                        Text(selection.service.rawValue)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selection.service.color)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MusicSearchView(
        musicService: MusicIntegrationService(),
        onMusicSelected: { _ in }
    )
}