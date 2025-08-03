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
    
    @StateObject private var musicPreferences = MusicPreferencesService.shared
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
                    
                    if musicPreferences.hasEnabledServices {
                        HStack(spacing: 12) {
                            ForEach(musicPreferences.enabledServices, id: \.self) { service in
                                MusicServiceButton(
                                    service: service,
                                    isSelected: selectedService == service,
                                    onSelect: { selectedService = service }
                                )
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Text("No music services enabled")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Button("Configure in Settings") {
                                presentationMode.wrappedValue.dismiss()
                                // This would ideally navigate to settings, but for now we'll just dismiss
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeColors.adaptivePrimary)
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
                        .disabled(searchQuery.isEmpty || !musicPreferences.hasEnabledServices)
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
            .background(ThemeColors.adaptiveSystemBackground)
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
            musicPreferences.checkTechnicalAvailability()
            // Auto-select user's preferred service
            if let preferredService = musicPreferences.preferredService {
                selectedService = preferredService
            } else if let firstEnabled = musicPreferences.enabledServices.first {
                selectedService = firstEnabled
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
            .background(isSelected ? service.color : ThemeColors.adaptiveSecondaryBackground)
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
            .background(ThemeColors.adaptiveSecondaryBackground)
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