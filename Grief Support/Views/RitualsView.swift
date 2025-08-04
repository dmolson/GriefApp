//
//  RitualsView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import PhotosUI
import UIKit

enum RitualType: String, CaseIterable, Codable {
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

struct RitualsView: View {
    @State private var savedRituals: [SavedRitual] = []
    @State private var selectedFilter = "View All"
    @State private var selectedRitualType: RitualType?
    @State private var selectedPerson = ""
    @State private var ritualDescription = ""
    @State private var ritualItems = ""
    @State private var ritualLocation = ""
    @State private var ritualMusicSelection = ""
    @State private var selectedMusic: MusicSelection?
    @State private var notificationEnabled = true
    @State private var notificationTime = Date()
    @State private var showingSaveConfirmation = false
    @StateObject private var musicService = MusicIntegrationService()
    @StateObject private var lovedOnesService = LovedOnesDataService.shared
    @State private var showingSettings = false
    
    var lovedOnes: [(String, String)] {
        return lovedOnesService.lovedOnesForRituals
    }
    
    var hasNoLovedOnes: Bool {
        return lovedOnesService.lovedOnes.isEmpty
    }
    
    var filteredRituals: [SavedRitual] {
        if selectedFilter == "View All" {
            return savedRituals
        } else {
            return savedRituals.filter { $0.personName.lowercased() == selectedFilter.lowercased() }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Header with + Button
                HStack {
                    Text("Rituals")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(ThemeColors.adaptivePrimary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 60) // Account for status bar
                .padding(.bottom, 20)
                .background(ThemeColors.adaptiveSystemBackground)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        // View Rituals Section
                        LazyVStack(alignment: .leading, spacing: 16) {
                            SectionHeaderView(title: "Your Rituals")
                        
                        // Filter Buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterButton(
                                    title: "View All",
                                    isSelected: selectedFilter == "View All",
                                    count: savedRituals.count,
                                    onTap: { selectedFilter = "View All" }
                                )
                                
                                ForEach(lovedOnes, id: \.1) { lovedOne in
                                    FilterButton(
                                        title: lovedOne.0,
                                        isSelected: selectedFilter == lovedOne.0,
                                        count: savedRituals.filter { $0.personName.lowercased() == lovedOne.1 }.count,
                                        onTap: { selectedFilter = lovedOne.0 }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Filtered Ritual Cards
                        if filteredRituals.isEmpty {
                            if hasNoLovedOnes {
                                // No loved ones state
                                VStack(spacing: 20) {
                                    Image(systemName: "person.badge.plus")
                                        .font(.system(size: 48))
                                        .foregroundColor(.secondary)
                                    
                                    Text("No Loved Ones Added Yet")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Add someone special to create meaningful rituals in their honor")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    
                                    Button(action: {
                                        showingSettings = true
                                    }) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Add Loved One")
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(ThemeColors.adaptivePrimary)
                                        .cornerRadius(25)
                                    }
                                }
                                .padding()
                                .padding(.vertical, 20)
                                .background(ThemeColors.adaptiveCardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            } else {
                                // No rituals state
                                VStack(spacing: 16) {
                                    Image(systemName: "heart.circle")
                                        .font(.system(size: 48))
                                        .foregroundColor(.secondary)
                                    
                                    Text(selectedFilter == "View All" ? "No Rituals Created" : "No Rituals for \(selectedFilter)")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Create your first ritual below to honor your loved one")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .padding(.vertical, 20)
                                .background(ThemeColors.adaptiveCardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                        } else {
                            ForEach(filteredRituals) { ritual in
                                SavedRitualCard(
                                    ritual: ritual,
                                    onEdit: { editingRitual in
                                        // TODO: Implement edit functionality
                                    },
                                    onDelete: { ritualToDelete in
                                        deleteSavedRitual(ritualToDelete)
                                    },
                                    onToggleNotification: { ritual, enabled in
                                        updateRitualNotification(ritual, enabled: enabled)
                                    }
                                )
                            }
                        }
                    }
                    
                    // Create Rituals Section
                    LazyVStack(alignment: .leading, spacing: 16) {
                        SectionHeaderView(title: "Create New Ritual")
                        
                        // Ritual Type Selection (with lighter background)
                        LazyVStack(alignment: .leading, spacing: 15) {
                            Text("Choose Ritual Type")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(RitualType.allCases, id: \.self) { type in
                                    RitualTypeCard(
                                        type: type,
                                        isSelected: selectedRitualType == type,
                                        onSelect: {
                                            selectedRitualType = type
                                            resetFormFields()
                                        }
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(ThemeColors.adaptiveCardBackground)
                        .cornerRadius(12)
                        
                        // Ritual Creation Form (when type is selected)
                        if let ritualType = selectedRitualType {
                            RitualCreationForm(
                                ritualType: ritualType,
                                selectedPerson: $selectedPerson,
                                ritualDescription: $ritualDescription,
                                ritualItems: $ritualItems,
                                ritualLocation: $ritualLocation,
                                ritualMusicSelection: $ritualMusicSelection,
                                selectedMusic: $selectedMusic,
                                notificationEnabled: $notificationEnabled,
                                notificationTime: $notificationTime,
                                lovedOnes: lovedOnes,
                                lovedOnesService: lovedOnesService,
                                musicService: musicService,
                                onSave: saveRitual,
                                onAddLovedOne: { showingSettings = true }
                            )
                        }
                    }
                }
                .padding()
                .padding(.top, 20) // Reduced padding since we have custom header
            }
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationBarHidden(true)
        }
        .alert("Ritual Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK") {
                resetFormFields()
            }
        } message: {
            Text("Your ritual has been saved successfully. You can access it from your saved rituals.")
        }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                LovedOnesSettingsView(currentScreen: .constant(.lovedOnes))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Done") {
                                showingSettings = false
                            }
                            .foregroundColor(ThemeColors.adaptivePrimary)
                        }
                    }
            }
        }
        .onAppear {
            loadSavedRituals()
        }
        .onChange(of: savedRituals) { _, _ in
            saveSavedRituals()
        }
    }
    
    private func resetFormFields() {
        selectedPerson = ""
        ritualDescription = ""
        ritualItems = ""
        ritualLocation = ""
        ritualMusicSelection = ""
        selectedMusic = nil
        notificationEnabled = true
        notificationTime = Date()
    }
    
    private func saveRitual() {
        guard let ritualType = selectedRitualType, !selectedPerson.isEmpty else { return }
        
        let ritual = SavedRitual(
            type: ritualType,
            personName: selectedPerson,
            description: ritualDescription,
            items: ritualItems.isEmpty ? nil : ritualItems,
            location: ritualLocation.isEmpty ? nil : ritualLocation,
            musicSelection: ritualMusicSelection.isEmpty ? nil : ritualMusicSelection,
            selectedMusic: selectedMusic,
            notificationEnabled: notificationEnabled,
            notificationTime: notificationTime
        )
        
        savedRituals.append(ritual)
        showingSaveConfirmation = true
        selectedRitualType = nil
    }
    
    private func updateRitualNotification(_ ritual: SavedRitual, enabled: Bool) {
        if let index = savedRituals.firstIndex(where: { $0.id == ritual.id }) {
            savedRituals[index].notificationEnabled = enabled
        }
    }
    
    private func loadSavedRituals() {
        if let data = UserDefaults.standard.data(forKey: "savedRituals"),
           let decoded = try? JSONDecoder().decode([SavedRitual].self, from: data) {
            savedRituals = decoded
        }
    }
    
    private func saveSavedRituals() {
        if let encoded = try? JSONEncoder().encode(savedRituals) {
            UserDefaults.standard.set(encoded, forKey: "savedRituals")
        }
    }
    
    private func deleteSavedRitual(_ ritual: SavedRitual) {
        savedRituals.removeAll { $0.id == ritual.id }
    }
}

// MARK: - Supporting Views

struct RitualCreationForm: View {
    let ritualType: RitualType
    @Binding var selectedPerson: String
    @Binding var ritualDescription: String
    @Binding var ritualItems: String
    @Binding var ritualLocation: String
    @Binding var ritualMusicSelection: String
    @Binding var selectedMusic: MusicSelection?
    @Binding var notificationEnabled: Bool
    @Binding var notificationTime: Date
    let lovedOnes: [(String, String)]
    @ObservedObject var lovedOnesService: LovedOnesDataService
    @ObservedObject var musicService: MusicIntegrationService
    let onSave: () -> Void
    let onAddLovedOne: () -> Void
    
    @State private var showingMusicSearch = false
    @State private var musicSearchQuery = ""
    
    var ritualGuidance: String {
        switch ritualType {
        case .connection:
            return "Connection rituals help you feel close to your loved one in daily life. Consider activities like morning coffee together, listening to their favorite music, or visiting meaningful places."
        case .reflection:
            return "Reflection rituals provide dedicated time to process emotions and memories. This might include journaling about them, meditation, or creating art in their honor."
        case .birthday:
            return "Birthday rituals celebrate your loved one's life on their special day. Consider their favorite cake, visiting their grave, or doing something they enjoyed."
        case .anniversary:
            return "Anniversary rituals honor the memory of your loved one on significant dates. This might include lighting a candle, sharing stories, or doing something meaningful together."
        }
    }
    
    var body: some View {
        CardView {
            LazyVStack(alignment: .leading, spacing: 20) {
                // Guidance Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ritual Guidance")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(ritualGuidance)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(ThemeColors.adaptiveTertiaryBackground)
                .cornerRadius(8)
                
                // Person Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose Loved One *")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Menu {
                        ForEach(lovedOnes, id: \.1) { lovedOne in
                            Button(lovedOne.0) {
                                selectedPerson = lovedOne.1
                            }
                        }
                        
                        Divider()
                        
                        Button(action: {
                            onAddLovedOne()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add Loved One")
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPerson.isEmpty ? "Select loved one" : selectedPerson.capitalized)
                                .foregroundColor(selectedPerson.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                        }
                        .padding()
                        .background(ThemeColors.adaptiveSecondaryBackground)
                        .cornerRadius(8)
                    }
                }
                
                // Description Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ritual Description")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $ritualDescription)
                        .frame(height: 80)
                        .padding(8)
                        .background(ThemeColors.adaptiveSecondaryBackground)
                        .cornerRadius(8)
                }
                
                // Optional Fields
                LazyVStack(alignment: .leading, spacing: 16) {
                    Text("Optional Details")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Items Needed")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("e.g., candles, photos, flowers", text: $ritualItems)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("e.g., garden, their favorite place", text: $ritualLocation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Music")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if let selectedMusic = selectedMusic {
                            // Selected music display
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: selectedMusic.service.icon)
                                            .foregroundColor(selectedMusic.service.color)
                                        Text(selectedMusic.title)
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    
                                    if !selectedMusic.artist.isEmpty {
                                        Text(selectedMusic.artist)
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    self.selectedMusic = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(ThemeColors.adaptiveTertiaryBackground)
                            .cornerRadius(8)
                        } else {
                            // Music search button
                            Button(action: {
                                showingMusicSearch = true
                            }) {
                                HStack {
                                    Image(systemName: "music.note.list")
                                        .foregroundColor(ThemeColors.adaptivePrimary)
                                    Text("Add Song or Playlist")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 12))
                                }
                                .padding()
                                .background(ThemeColors.adaptiveSecondaryBackground)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Fallback text field for manual entry
                        TextField("Or enter song/artist name", text: $ritualMusicSelection)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 14))
                    }
                }
                
                // Notification Settings
                LazyVStack(alignment: .leading, spacing: 12) {
                    Text("Reminder Settings")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("Enable Reminder")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        CustomToggle(isOn: $notificationEnabled)
                    }
                    
                    if notificationEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reminder Time")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                    }
                }
                
                // Save Button
                PrimaryButton(title: "Save Ritual") {
                    onSave()
                }
                .disabled(selectedPerson.isEmpty)
            }
        }
        .sheet(isPresented: $showingMusicSearch) {
            MusicSearchView(
                musicService: musicService,
                onMusicSelected: { music in
                    selectedMusic = music
                    showingMusicSearch = false
                }
            )
        }
    }
}

struct SavedRitualCard: View {
    let ritual: SavedRitual
    let onEdit: (SavedRitual) -> Void
    let onDelete: (SavedRitual) -> Void
    let onToggleNotification: (SavedRitual, Bool) -> Void
    @State private var showingDeleteConfirmation = false
    @StateObject private var musicService = MusicIntegrationService()
    
    var body: some View {
        CardView {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: ritual.type.icon)
                            .foregroundColor(ThemeColors.adaptivePrimary)
                            .font(.system(size: 16))
                        
                        Text(ritual.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                        }
                    }
                    
                    if !ritual.description.isEmpty {
                        Text(ritual.description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    // Music info if available
                    if let selectedMusic = ritual.selectedMusic {
                        HStack(spacing: 8) {
                            Image(systemName: selectedMusic.service.icon)
                                .foregroundColor(selectedMusic.service.color)
                                .font(.system(size: 12))
                            
                            Text(selectedMusic.title)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            if !selectedMusic.artist.isEmpty {
                                Text("• \(selectedMusic.artist)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    await playMusic()
                                }
                            } label: {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(selectedMusic.service.color)
                                    .font(.system(size: 18))
                            }
                        }
                        .padding(.top, 4)
                    } else if let musicText = ritual.musicSelection, !musicText.isEmpty {
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                            
                            Text(musicText)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .padding(.top, 4)
                    }
                    
                    Text("Created \(ritual.dateCreated.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .alert("Delete Ritual?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete(ritual)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete '\(ritual.name)'. This action cannot be undone.")
        }
    }
    
    private func playMusic() async {
        guard let selectedMusic = ritual.selectedMusic else { return }
        
        let success = await musicService.playMusicSelection(selectedMusic)
        if !success {
            print("Failed to play music: \(selectedMusic.title)")
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : ThemeColors.adaptivePrimary)
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.3) : ThemeColors.adaptiveSecondaryBackground)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? ThemeColors.adaptivePrimary : ThemeColors.adaptiveSecondaryBackground)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RitualTypeCard: View {
    let type: RitualType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(ThemeColors.adaptivePrimary)
                
                Text(type.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(isSelected ? ThemeColors.adaptivePrimary.opacity(0.1) : ThemeColors.adaptiveSecondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.adaptivePrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RitualStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Step Number Circle
            Text("\(number)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(ThemeColors.adaptivePrimaryBackground)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(15)
        .background(ThemeColors.adaptiveSecondaryBackground)
        .cornerRadius(8)
        .overlay(
            Rectangle()
                .frame(width: 4)
                .foregroundColor(ThemeColors.adaptivePrimaryBackground)
                .cornerRadius(2),
            alignment: .leading
        )
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    let maxSelection: Int
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = maxSelection
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let uiImage = image as? UIImage {
                            // Resize image to limit memory usage
                            let resizedImage = self.resizeImage(uiImage, maxSize: CGSize(width: 1024, height: 1024))
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(resizedImage)
                            }
                        }
                    }
                }
            }
        }
        
        private func resizeImage(_ image: UIImage, maxSize: CGSize) -> UIImage {
            let size = image.size
            
            // Don't resize if already within limits
            if size.width <= maxSize.width && size.height <= maxSize.height {
                return image
            }
            
            let widthRatio = maxSize.width / size.width
            let heightRatio = maxSize.height / size.height
            let ratio = min(widthRatio, heightRatio)
            
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
            
            return resizedImage
        }
    }
}

// MARK: - SavedRitual Data Structure
struct SavedRitual: Identifiable, Codable, Equatable {
    let id: UUID
    var type: RitualType
    var name: String
    var personName: String
    var description: String
    var items: String?
    var location: String?
    var musicSelection: String?
    var selectedMusic: MusicSelection?
    var notificationEnabled: Bool
    var notificationTime: Date
    var dateCreated: Date
    
    init(type: RitualType, personName: String, description: String = "", items: String? = nil, location: String? = nil, musicSelection: String? = nil, selectedMusic: MusicSelection? = nil, notificationEnabled: Bool = true, notificationTime: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.name = "\(personName)'s \(type.rawValue)"
        self.personName = personName
        self.description = description
        self.items = items
        self.location = location
        self.musicSelection = musicSelection
        self.selectedMusic = selectedMusic
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.dateCreated = Date()
    }
    
    static func == (lhs: SavedRitual, rhs: SavedRitual) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    RitualsView()
}
