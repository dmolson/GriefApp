//
//  RitualsView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import PhotosUI
import UIKit

enum RitualType: String, CaseIterable {
    case connection = "Connection Ritual"
    case reflection = "Reflection Ritual"
    case birthday = "Birthday Ritual"
    case anniversary = "Anniversary Ritual"
    
    var icon: String {
        switch self {
        case .connection: return "sunrise.fill"
        case .reflection: return "moon.fill"
        case .birthday: return "birthday.cake.fill"
        case .anniversary: return "calendar.badge.plus"
        }
    }
}

struct MusicSelection {
    let id: String
    let title: String
    let artist: String
    let type: MusicType
    let service: MusicService
    let artworkURL: String?
    
    enum MusicType {
        case song
        case playlist
    }
    
    enum MusicService {
        case spotify
        case appleMusic
    }
}

struct RitualsView: View {
    @State private var selectedRitualType: RitualType?
    @State private var selectedPerson = ""
    @State private var customIdeas = ""
    @State private var connectionPrompts = ""
    @State private var reflectionPrompts = ""
    @State private var itemsText = ""
    @State private var selectedImages: [UIImage] = []
    @State private var selectedPresetImage: String? = nil
    @State private var showingImagePicker = false
    @State private var showingPhotoSavedAlert = false
    @State private var photoSavedMessage = ""
    @State private var showingLovedOnesSettings = false
    @State private var selectedPersonFilter = "Create"
    @State private var selectedMusic: MusicSelection? = nil
    @State private var showingMusicPicker = false
    @State private var showingMusicPlayer = false
    @State private var showingRitualPlayback = false
    @AppStorage("spotifyConnected") private var spotifyConnected = false
    @AppStorage("appleMusicConnected") private var appleMusicConnected = false
    
    let lovedOnes = ["All", "Matthew", "Mom", "Smudge"]
    
    var body: some View {
        Text("Test")
    }
}