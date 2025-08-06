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
    @State private var notificationEnabled = true
    @State private var notificationTime = Date()
    @State private var selectedDays: Set<Int> = Set(0...6) // Default to all days
    @State private var showingSaveConfirmation = false
    @State private var selectedRitualPhoto: UIImage? = nil
    @StateObject private var lovedOnesService = LovedOnesDataService.shared
    @State private var showingSettings = false
    @State private var editingRitual: SavedRitual?
    @Environment(\.scenePhase) private var scenePhase
    private let notificationService = NotificationService.shared
    @EnvironmentObject var notificationCoordinator: NotificationCoordinator
    @State private var showingRitualViewer = false
    @State private var ritualToView: SavedRitual?
    
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
            return savedRituals.filter { $0.personName.caseInsensitiveCompare(selectedFilter) == .orderedSame }
        }
    }
    
    @ViewBuilder
    var ritualListContent: some View {
        if filteredRituals.isEmpty {
            if hasNoLovedOnes {
                noLovedOnesView
            } else {
                noRitualsView
            }
        } else {
            ForEach(filteredRituals) { ritual in
                SavedRitualCard(
                    ritual: ritual,
                    onEdit: { ritualToEdit in
                        editingRitual = ritualToEdit
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
    
    @ViewBuilder
    var noLovedOnesView: some View {
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
    }
    
    @ViewBuilder
    var noRitualsView: some View {
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
    
    @ViewBuilder
    var headerSection: some View {
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
    }
    
    @ViewBuilder
    var yourRitualsSection: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Your Rituals")
                .id("yourRituals") // Scroll anchor
            
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
                            count: savedRituals.filter { $0.personName.caseInsensitiveCompare(lovedOne.0) == .orderedSame }.count,
                            onTap: { selectedFilter = lovedOne.0 }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Filtered Ritual Cards
            ritualListContent
        }
    }
    
    @ViewBuilder
    func createRitualSection(scrollProxy: ScrollViewProxy) -> some View {
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
                    notificationEnabled: $notificationEnabled,
                    notificationTime: $notificationTime,
                    selectedDays: $selectedDays,
                    lovedOnes: lovedOnes,
                    selectedPhoto: $selectedRitualPhoto,
                    lovedOnesService: lovedOnesService,
                    onSave: {
                        saveRitual()
                        withAnimation {
                            scrollProxy.scrollTo("yourRituals", anchor: .top)
                        }
                    },
                    onAddLovedOne: { showingSettings = true }
                )
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            yourRitualsSection
                            createRitualSection(scrollProxy: scrollProxy)
                        }
                        .padding()
                        .padding(.top, 20)
                    }
                }
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationBarHidden(true)
        }
        .alert("Ritual Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK") {
                // Form is already hidden, just dismiss the alert
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
        .sheet(item: $editingRitual) { ritual in
            EditRitualSheet(
                ritual: ritual,
                lovedOnes: lovedOnes,
                onSave: { updatedRitual in
                    updateRitual(updatedRitual)
                    editingRitual = nil
                },
                onCancel: {
                    editingRitual = nil
                }
            )
        }
        .onAppear {
            loadSavedRituals()
            
            // Request notification permission if needed
            Task {
                let status = await notificationService.checkNotificationPermission()
                if status == .notDetermined {
                    _ = await notificationService.requestNotificationPermission()
                }
            }
            
            // Check if we need to open a specific ritual from notification
            checkForRitualToOpen()
        }
        .onChange(of: notificationCoordinator.shouldNavigateToRitual) { _, shouldNavigate in
            if shouldNavigate {
                checkForRitualToOpen()
            }
        }
        .fullScreenCover(item: $ritualToView) { ritual in
            RitualViewerView(ritual: ritual, isPresented: Binding(
                get: { ritualToView != nil },
                set: { if !$0 { ritualToView = nil } }
            ))
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("RitualsResetNotification"))) { _ in
            // Clear the local state and reload when rituals are reset from Settings
            savedRituals = []
            loadSavedRituals()
        }
        .onChange(of: savedRituals) { _, _ in
            saveSavedRituals()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                loadSavedRituals()
            }
        }
    }
    
    private func resetFormFields() {
        selectedPerson = ""
        ritualDescription = ""
        ritualItems = ""
        ritualLocation = ""
        ritualMusicSelection = ""
        notificationEnabled = true
        notificationTime = Date()
        selectedDays = Set(0...6) // Reset to all days
        selectedRitualPhoto = nil
    }
    
    private func saveRitual() {
        guard let ritualType = selectedRitualType, !selectedPerson.isEmpty else { return }
        
        // Save photo if one was selected
        var photoFilename: String? = nil
        if let photo = selectedRitualPhoto {
            photoFilename = PhotoManager.shared.savePhoto(photo)
        }
        
        let ritual = SavedRitual(
            type: ritualType,
            personName: selectedPerson,
            description: ritualDescription,
            items: ritualItems.isEmpty ? nil : ritualItems,
            location: ritualLocation.isEmpty ? nil : ritualLocation,
            musicSelection: ritualMusicSelection.isEmpty ? nil : ritualMusicSelection,
            photoFilename: photoFilename,
            notificationEnabled: notificationEnabled,
            notificationTime: notificationTime,
            selectedDays: selectedDays
        )
        
        savedRituals.append(ritual)
        saveSavedRituals() // Persist to UserDefaults
        
        // Schedule notification if enabled
        if ritual.notificationEnabled {
            Task {
                await notificationService.scheduleRitualNotification(ritual)
            }
        }
        
        // Reset everything and hide the form immediately
        resetFormFields()
        selectedRitualType = nil  // Hide the form to show the ritual list
        showingSaveConfirmation = true
    }
    
    private func updateRitualNotification(_ ritual: SavedRitual, enabled: Bool) {
        if let index = savedRituals.firstIndex(where: { $0.id == ritual.id }) {
            savedRituals[index].notificationEnabled = enabled
            saveSavedRituals() // Persist to UserDefaults
            
            // Update the notification in the notification service
            Task {
                await notificationService.updateRitualNotification(savedRituals[index])
            }
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
        // Delete associated photo if it exists
        PhotoManager.shared.deletePhotosForRitual(ritual)
        
        // Cancel the notification before deleting
        notificationService.cancelRitualNotification(ritual)
        savedRituals.removeAll { $0.id == ritual.id }
        saveSavedRituals() // Persist to UserDefaults
    }
    
    private func updateRitual(_ updatedRitual: SavedRitual) {
        if let index = savedRituals.firstIndex(where: { $0.id == updatedRitual.id }) {
            savedRituals[index] = updatedRitual
            saveSavedRituals() // Persist to UserDefaults
            
            // Update the notification
            Task {
                await notificationService.updateRitualNotification(updatedRitual)
            }
        }
    }
    
    private func checkForRitualToOpen() {
        guard let ritualId = notificationCoordinator.ritualIdToOpen,
              let ritual = savedRituals.first(where: { $0.id.uuidString == ritualId }) else {
            return
        }
        
        // Open the ritual viewer
        ritualToView = ritual
        
        // Reset the coordinator
        notificationCoordinator.resetNavigation()
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
    @Binding var notificationEnabled: Bool
    @Binding var notificationTime: Date
    @Binding var selectedDays: Set<Int>
    let lovedOnes: [(String, String)]
    
    @Binding var selectedPhoto: UIImage?
    @State private var showingPhotoPicker = false
    @ObservedObject var lovedOnesService: LovedOnesDataService
    let onSave: () -> Void
    let onAddLovedOne: () -> Void
    
    var ritualGuidance: String {
        switch ritualType {
        case .connection:
            return "Connection rituals help you feel close to your loved one in daily life. Consider activities like morning coffee together, listening to their favorite music, or visiting meaningful places."
        case .reflection:
            return "Reflection rituals provide dedicated time to process emotions and memories. This might include journaling about them, meditation, or creating art in their honor."
        case .birthday:
            return "Birthday rituals celebrate your loved one's life on their special day. Consider their favorite cake, visiting their grave, or doing something they enjoyed."
        case .anniversary:
            return "Anniversary rituals honor the memory of your loved one on the anniversary of their passing. This might include lighting a candle, sharing stories, or doing something meaningful together."
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
                                selectedPerson = lovedOne.0  // Use the original case name
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
                            Text(selectedPerson.isEmpty ? "Select loved one" : selectedPerson)
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
                        
                        // Manual music entry only
                        TextField("Enter song/artist name", text: $ritualMusicSelection)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 14))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photo (Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if let selectedPhoto = selectedPhoto {
                            HStack {
                                Image(uiImage: selectedPhoto)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .cornerRadius(8)
                                
                                Spacer()
                                
                                Button("Remove") {
                                    self.selectedPhoto = nil
                                }
                                .foregroundColor(.red)
                                .font(.system(size: 14, weight: .medium))
                            }
                        } else {
                            Button(action: {
                                showingPhotoPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Add Photo")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ThemeColors.adaptivePrimary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(ThemeColors.adaptiveSecondaryBackground)
                                .cornerRadius(8)
                            }
                        }
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
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Reminder Time")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                            }
                            
                            // Only show day selection for Connection and Reflection rituals
                            if ritualType == .connection || ritualType == .reflection {
                                Divider()
                                DaySelectionView(selectedDays: $selectedDays)
                            }
                            
                            // Show informational text for Birthday and Anniversary rituals
                            if ritualType == .birthday {
                                if !selectedPerson.isEmpty,
                                   let birthDate = lovedOnesService.getBirthDate(for: selectedPerson) {
                                    Text("Notification will be sent annually on \(selectedPerson)'s birthday (\(birthDate))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .italic()
                                        .padding(.top, 8)
                                }
                            } else if ritualType == .anniversary {
                                if !selectedPerson.isEmpty,
                                   let passDate = lovedOnesService.getPassDate(for: selectedPerson) {
                                    Text("Notification will be sent annually on \(selectedPerson)'s memorial date (\(passDate))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .italic()
                                        .padding(.top, 8)
                                }
                            }
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
        .sheet(isPresented: $showingPhotoPicker) {
            SinglePhotoPicker(selectedPhoto: $selectedPhoto)
        }
    }
}

struct SavedRitualCard: View {
    let ritual: SavedRitual
    let onEdit: (SavedRitual) -> Void
    let onDelete: (SavedRitual) -> Void
    let onToggleNotification: (SavedRitual, Bool) -> Void
    @State private var showingDeleteConfirmation = false
    @State private var showingActionSheet = false
    @State private var showingRitualViewer = false
    
    private func getAnnualDateDisplay(for ritual: SavedRitual) -> String {
        let lovedOnesService = LovedOnesDataService.shared
        
        if ritual.type == .birthday {
            if let birthDate = lovedOnesService.getBirthDate(for: ritual.personName) {
                // Parse the date to get month and day
                let formatters = [
                    createDateFormatter(format: "MMMM d, yyyy"),
                    createDateFormatter(format: "MMM d, yyyy"),
                    createDateFormatter(format: "M/d/yyyy"),
                    createDateFormatter(format: "yyyy-MM-dd")
                ]
                
                for formatter in formatters {
                    if let date = formatter.date(from: birthDate) {
                        let displayFormatter = DateFormatter()
                        displayFormatter.dateFormat = "MMM d"
                        return "Birthday: \(displayFormatter.string(from: date))"
                    }
                }
            }
            return "Birthday"
        } else if ritual.type == .anniversary {
            if let passDate = lovedOnesService.getPassDate(for: ritual.personName) {
                // Parse the date to get month and day
                let formatters = [
                    createDateFormatter(format: "MMMM d, yyyy"),
                    createDateFormatter(format: "MMM d, yyyy"),
                    createDateFormatter(format: "M/d/yyyy"),
                    createDateFormatter(format: "yyyy-MM-dd")
                ]
                
                for formatter in formatters {
                    if let date = formatter.date(from: passDate) {
                        let displayFormatter = DateFormatter()
                        displayFormatter.dateFormat = "MMM d"
                        return "Anniversary: \(displayFormatter.string(from: date))"
                    }
                }
            }
            return "Anniversary"
        }
        
        return ""
    }
    
    private func createDateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    var body: some View {
        Button(action: {
            showingRitualViewer = true
        }) {
            CardView {
                HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: ritual.type.icon)
                            .foregroundColor(ThemeColors.adaptivePrimary)
                            .font(.system(size: 16))
                        
                        Text(ritual.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if ritual.notificationEnabled {
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            // Show date for Birthday/Anniversary, days for other rituals
                            if ritual.type == .birthday || ritual.type == .anniversary {
                                Text(getAnnualDateDisplay(for: ritual))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            } else {
                                Text(ritual.selectedDaysDisplay)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingActionSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16, weight: .medium))
                                .padding(8)
                                .background(ThemeColors.adaptiveTertiaryBackground)
                                .clipShape(Circle())
                        }
                    }
                    
                    if !ritual.description.isEmpty {
                        Text(ritual.description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    // Music info if available
                    if let musicText = ritual.musicSelection, !musicText.isEmpty {
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
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingRitualViewer) {
            RitualViewerView(ritual: ritual, isPresented: $showingRitualViewer)
        }
        .confirmationDialog("Manage Ritual", isPresented: $showingActionSheet, titleVisibility: .visible) {
            Button("Edit Details") {
                onEdit(ritual)
            }
            
            Button("Delete", role: .destructive) {
                showingDeleteConfirmation = true
            }
            
            Button("Cancel", role: .cancel) { }
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
    var photoFilename: String?
    var notificationEnabled: Bool
    var notificationTime: Date
    var selectedDays: Set<Int> // 0=Sunday, 1=Monday, ..., 6=Saturday
    var dateCreated: Date
    
    init(type: RitualType, personName: String, description: String = "", items: String? = nil, location: String? = nil, musicSelection: String? = nil, photoFilename: String? = nil, notificationEnabled: Bool = true, notificationTime: Date = Date(), selectedDays: Set<Int>? = nil) {
        self.id = UUID()
        self.type = type
        self.name = "\(personName)'s \(type.rawValue)"
        self.personName = personName
        self.description = description
        self.items = items
        self.location = location
        self.musicSelection = musicSelection
        self.photoFilename = photoFilename
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.selectedDays = selectedDays ?? Set(0...6) // Default to all days
        self.dateCreated = Date()
    }
    
    // Custom decoder for migration support
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(RitualType.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.personName = try container.decode(String.self, forKey: .personName)
        self.description = try container.decode(String.self, forKey: .description)
        self.items = try? container.decode(String.self, forKey: .items)
        self.location = try? container.decode(String.self, forKey: .location)
        self.musicSelection = try? container.decode(String.self, forKey: .musicSelection)
        self.photoFilename = try? container.decode(String.self, forKey: .photoFilename)
        self.notificationEnabled = try container.decode(Bool.self, forKey: .notificationEnabled)
        self.notificationTime = try container.decode(Date.self, forKey: .notificationTime)
        // If selectedDays doesn't exist (old format), default to all days
        self.selectedDays = (try? container.decode(Set<Int>.self, forKey: .selectedDays)) ?? Set(0...6)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, type, name, personName, description, items, location, musicSelection, photoFilename
        case notificationEnabled, notificationTime, selectedDays, dateCreated
    }
    
    static func == (lhs: SavedRitual, rhs: SavedRitual) -> Bool {
        lhs.id == rhs.id
    }
    
    // Helper to get display string for selected days (consistent with Reminder)
    var selectedDaysDisplay: String {
        if selectedDays.count == 7 {
            return "Every day"
        } else if selectedDays.count == 0 {
            return "No days selected"
        } else {
            let dayAbbreviations = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            let sortedDays = selectedDays.sorted()
            let abbreviated = sortedDays.map { dayAbbreviations[$0] }.joined(separator: ", ")
            return abbreviated
        }
    }
}

// MARK: - Edit Ritual Sheet
struct EditRitualSheet: View {
    let ritual: SavedRitual
    let lovedOnes: [(String, String)]
    let onSave: (SavedRitual) -> Void
    let onCancel: () -> Void
    
    @State private var editedType: RitualType
    @State private var editedPersonName: String
    @State private var editedDescription: String
    @State private var editedItems: String
    @State private var editedLocation: String
    @State private var editedMusicSelection: String
    @State private var editedNotificationEnabled: Bool
    @State private var editedNotificationTime: Date
    @State private var editedSelectedDays: Set<Int>
    @Environment(\.dismiss) private var dismiss
    
    init(ritual: SavedRitual, lovedOnes: [(String, String)], onSave: @escaping (SavedRitual) -> Void, onCancel: @escaping () -> Void) {
        self.ritual = ritual
        self.lovedOnes = lovedOnes
        self.onSave = onSave
        self.onCancel = onCancel
        
        // Initialize state with current values
        _editedType = State(initialValue: ritual.type)
        _editedPersonName = State(initialValue: ritual.personName)
        _editedDescription = State(initialValue: ritual.description)
        _editedItems = State(initialValue: ritual.items ?? "")
        _editedLocation = State(initialValue: ritual.location ?? "")
        _editedMusicSelection = State(initialValue: ritual.musicSelection ?? "")
        _editedNotificationEnabled = State(initialValue: ritual.notificationEnabled)
        _editedNotificationTime = State(initialValue: ritual.notificationTime)
        _editedSelectedDays = State(initialValue: ritual.selectedDays)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Ritual Type Section
                    CardView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Ritual Type")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Menu {
                                ForEach(RitualType.allCases, id: \.self) { type in
                                    Button {
                                        editedType = type
                                    } label: {
                                        HStack {
                                            Image(systemName: type.icon)
                                            Text(type.rawValue)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: editedType.icon)
                                        .foregroundColor(ThemeColors.adaptivePrimary)
                                    Text(editedType.rawValue)
                                        .foregroundColor(.primary)
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
                    }
                    
                    // Person Selection Section
                    CardView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Loved One")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Menu {
                                ForEach(lovedOnes, id: \.1) { lovedOne in
                                    Button(lovedOne.0) {
                                        editedPersonName = lovedOne.1
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(editedPersonName.isEmpty ? "Select loved one" : editedPersonName)
                                        .foregroundColor(editedPersonName.isEmpty ? .secondary : .primary)
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
                    }
                    
                    // Description Section
                    CardView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Description")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $editedDescription)
                                .frame(height: 100)
                                .padding(8)
                                .background(ThemeColors.adaptiveSecondaryBackground)
                                .cornerRadius(8)
                        }
                    }
                    
                    // Optional Details Section
                    CardView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Optional Details")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Items Needed")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    TextField("e.g., candles, photos, flowers", text: $editedItems)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Location")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    TextField("e.g., garden, their favorite place", text: $editedLocation)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Music")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    TextField("Enter song/artist name", text: $editedMusicSelection)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                    }
                    
                    // Notification Settings Section
                    CardView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Reminder Settings")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("Enable Reminder")
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                                CustomToggle(isOn: $editedNotificationEnabled)
                            }
                            
                            if editedNotificationEnabled {
                                VStack(alignment: .leading, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Reminder Time")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        DatePicker("", selection: $editedNotificationTime, displayedComponents: .hourAndMinute)
                                            .datePickerStyle(CompactDatePickerStyle())
                                            .labelsHidden()
                                    }
                                    
                                    // Only show day selection for Connection and Reflection rituals
                                    if editedType == .connection || editedType == .reflection {
                                        Divider()
                                        DaySelectionView(selectedDays: $editedSelectedDays)
                                    }
                                    
                                    // Show informational text for Birthday and Anniversary rituals
                                    if editedType == .birthday {
                                        if !editedPersonName.isEmpty,
                                           let birthDate = LovedOnesDataService.shared.getBirthDate(for: editedPersonName) {
                                            Text("Notification will be sent annually on \(editedPersonName)'s birthday (\(birthDate))")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                                .italic()
                                                .padding(.top, 8)
                                        }
                                    } else if editedType == .anniversary {
                                        if !editedPersonName.isEmpty,
                                           let passDate = LovedOnesDataService.shared.getPassDate(for: editedPersonName) {
                                            Text("Notification will be sent annually on \(editedPersonName)'s memorial date (\(passDate))")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                                .italic()
                                                .padding(.top, 8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationTitle("Edit Ritual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(ThemeColors.adaptivePrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(ThemeColors.adaptivePrimary)
                    .fontWeight(.semibold)
                    .disabled(editedPersonName.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedRitual = ritual
        updatedRitual.type = editedType
        updatedRitual.personName = editedPersonName
        updatedRitual.name = "\(editedPersonName)'s \(editedType.rawValue)"
        updatedRitual.description = editedDescription
        updatedRitual.items = editedItems.isEmpty ? nil : editedItems
        updatedRitual.location = editedLocation.isEmpty ? nil : editedLocation
        updatedRitual.musicSelection = editedMusicSelection.isEmpty ? nil : editedMusicSelection
        updatedRitual.notificationEnabled = editedNotificationEnabled
        updatedRitual.notificationTime = editedNotificationTime
        updatedRitual.selectedDays = editedSelectedDays
        updatedRitual.dateCreated = ritual.dateCreated  // Preserve the original creation date
        
        onSave(updatedRitual)
    }
}

struct SinglePhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedPhoto: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: SinglePhotoPicker
        
        init(parent: SinglePhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let result = results.first else { return }
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let uiImage = image as? UIImage {
                        // Resize image to limit memory usage
                        let resizedImage = self.resizeImage(uiImage, maxSize: CGSize(width: 1024, height: 1024))
                        DispatchQueue.main.async {
                            self.parent.selectedPhoto = resizedImage
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

#Preview {
    RitualsView()
}
