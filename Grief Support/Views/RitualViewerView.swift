//
//  RitualViewerView.swift
//  Grief Support
//
//  Created by Claude on 8/6/25.
//

import SwiftUI

struct RitualViewerView: View {
    let ritual: SavedRitual
    @Binding var isPresented: Bool
    
    @State private var showingFullRitual = false
    @State private var contentOpacity = 0.0
    @State private var progressWidth: CGFloat = 0
    
    private var ritualSubtitle: String {
        switch ritual.type {
        case .connection:
            return "Take time to feel close to your loved one"
        case .reflection:
            return "Take a moment to honor your feelings and memories in this quiet space"
        case .birthday:
            return "Celebrate the life and legacy of your loved one on their special day"
        case .anniversary:
            return "Honor the memory and impact of your loved one"
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            ThemeColors.adaptiveSystemBackground
                .ignoresSafeArea()
            
            if !showingFullRitual {
                // Pre-ritual view
                preRitualView
                    .transition(.opacity)
            } else {
                // Full-screen ritual view
                fullRitualView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 1.0), value: showingFullRitual)
    }
    
    private var preRitualView: some View {
        VStack(spacing: 0) {
            // Close button at top
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .padding()
            }
            
            Spacer()
            
            VStack(spacing: 24) {
                // Candle icon
                Image("candle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .foregroundColor(ThemeColors.adaptivePrimary)
                
                // Title
                Text(ritual.type.rawValue)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(ThemeColors.adaptivePrimary)
                
                // Subtitle
                Text(ritualSubtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Recommendation
                Text("We recommend turning off notifications and minimizing distractions to create a peaceful environment for your ritual.")
                    .font(.system(size: 14))
                    .italic()
                    .foregroundColor(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                
                // Begin button
                Button(action: {
                    withAnimation {
                        showingFullRitual = true
                    }
                    // Start content animation after transition (faster timing)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn(duration: 1)) {
                            contentOpacity = 1.0
                        }
                    }
                    // Start progress animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.linear(duration: 30)) {
                            progressWidth = 1.0
                        }
                    }
                }) {
                    Text("Begin Ritual")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(ThemeColors.adaptivePrimary)
                        .cornerRadius(30)
                }
                .padding(.top, 16)
            }
            
            Spacer()
        }
    }
    
    private var fullRitualView: some View {
        ZStack {
            // Content
            VStack {
                // Header with candle and X button
                HStack {
                    // Semi-transparent candle
                    Image("candle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 35)
                        .opacity(0.3)
                        .padding(.leading)
                    
                    Spacer()
                    
                    // Exit button
                    Button(action: {
                        withAnimation {
                            showingFullRitual = false
                            contentOpacity = 0
                            progressWidth = 0
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(ThemeColors.adaptiveSecondaryBackground)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.adaptivePrimary)
                        }
                    }
                    .padding(.trailing)
                }
                .padding(.top, 20)
                
                // Main content
                ScrollView {
                    VStack(spacing: 40) {
                        // Person's name - using system font for consistency
                        Text(ritual.personName)
                            .font(.system(size: 36, weight: .bold))  // Larger, consistent with app's font system
                            .foregroundColor(ThemeColors.adaptivePrimary)
                            .multilineTextAlignment(.center)  // Center align for proper wrapping
                            .lineLimit(2)  // Max 2 lines for very long names
                            .minimumScaleFactor(0.7)  // Scale down if needed to fit
                            .opacity(contentOpacity)
                            .offset(y: contentOpacity == 1 ? 0 : 20)
                            .padding(.horizontal)  // Add padding to prevent edge touching
                        
                        // Ritual photo if available
                        if let photoFilename = ritual.photoFilename,
                           let image = PhotoManager.shared.loadPhoto(photoFilename) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(12)
                                .opacity(contentOpacity)
                                .offset(y: contentOpacity == 1 ? 0 : 20)
                                .padding(.horizontal)
                        }
                        
                        // Ritual description
                        if !ritual.description.isEmpty {
                            VStack(spacing: 16) {
                                Text("Your Ritual")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(ThemeColors.adaptivePrimary)
                                
                                Text(ritual.description)
                                    .font(.system(size: 18))
                                    .italic()
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(8)
                            }
                            .opacity(contentOpacity)
                            .offset(y: contentOpacity == 1 ? 0 : 20)
                            .padding(.horizontal)
                        }
                        
                        // Items
                        if let items = ritual.items, !items.isEmpty {
                            VStack(spacing: 16) {
                                Text("Items for Ritual")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(ThemeColors.adaptivePrimary)
                                
                                Text(items)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .opacity(contentOpacity)
                            .offset(y: contentOpacity == 1 ? 0 : 20)
                            .padding(.horizontal)
                        }
                        
                        // Location
                        if let location = ritual.location, !location.isEmpty {
                            VStack(spacing: 16) {
                                Text("Sacred Space")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(ThemeColors.adaptivePrimary)
                                
                                Text(location)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .opacity(contentOpacity)
                            .offset(y: contentOpacity == 1 ? 0 : 20)
                            .padding(.horizontal)
                        }
                        
                        // Music
                        if let music = ritual.musicSelection, !music.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "music.note")
                                    .font(.system(size: 24))
                                    .foregroundColor(ThemeColors.adaptivePrimary)
                                
                                Text(music)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(ThemeColors.adaptiveSecondaryBackground)
                            .cornerRadius(16)
                            .opacity(contentOpacity)
                            .offset(y: contentOpacity == 1 ? 0 : 20)
                            .padding(.horizontal)
                        }
                        
                        // Empty state if no content
                        if ritual.description.isEmpty && 
                           (ritual.items ?? "").isEmpty && 
                           (ritual.location ?? "").isEmpty && 
                           (ritual.musicSelection ?? "").isEmpty {
                            Text("This ritual space is waiting for your memories and reflections.")
                                .font(.system(size: 16))
                                .italic()
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                                .opacity(contentOpacity)
                        }
                    }
                    .padding(.vertical, 60)
                }
                
                Spacer()
            }
            
            // Progress bar at bottom
            VStack {
                Spacer()
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 4)
                        
                        // Progress
                        Rectangle()
                            .fill(ThemeColors.adaptivePrimary.opacity(0.4))
                            .frame(width: geometry.size.width * progressWidth, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// Preview
struct RitualViewerView_Previews: PreviewProvider {
    static var previews: some View {
        RitualViewerView(
            ritual: SavedRitual(
                type: .reflection,
                personName: "Matthew",
                description: "I miss the way you laughed at my terrible jokes. The kitchen feels too quiet without your humming while cooking.",
                items: "Your favorite mug, a photo from our trip",
                location: "The garden bench",
                musicSelection: "The Long and Winding Road - The Beatles"
            ),
            isPresented: .constant(true)
        )
    }
}