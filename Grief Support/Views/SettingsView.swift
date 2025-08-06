//
//  SettingsView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import MessageUI
import UserNotifications

// Helper extension for date parsing
extension DateFormatter {
    static func createFormatter(dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter
    }
    
    static func createFormatter(dateStyle: DateFormatter.Style) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        return formatter
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentScreen: SettingsScreen = .main
    @State private var showingResetConfirmation = false
    @State private var resetType = ""
    @State private var showingBugReport = false
    
    enum SettingsScreen {
        case main
        case lovedOnes
        case appearance
        case reset
        case integrations
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch currentScreen {
                case .main:
                    mainSettingsView
                case .lovedOnes:
                    LovedOnesSettingsView(currentScreen: $currentScreen)
                case .appearance:
                    AppearanceSettingsView(currentScreen: $currentScreen)
                case .reset:
                    ResetSettingsView(currentScreen: $currentScreen)
                case .integrations:
                    IntegrationsSettingsView(currentScreen: $currentScreen)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentScreen != .main {
                        Button(action: { currentScreen = .main }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(ThemeColors.adaptivePrimaryText)
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(navigationTitle)
                        .font(.appHeadline)
                        .foregroundColor(ThemeColors.adaptivePrimaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(ThemeColors.adaptivePrimaryText)
                    }
                }
            }
            .toolbarBackground(ThemeColors.adaptivePrimaryBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $showingBugReport) {
            BugReportView()
        }
    }
    
    var navigationTitle: String {
        switch currentScreen {
        case .main: return "Settings"
        case .lovedOnes: return "Your Loved Ones"
        case .appearance: return "Appearance"
        case .reset: return "Reset Saved Data"
        case .integrations: return "App Integrations"
        }
    }
    
    var mainSettingsView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                SettingsNavigationItem(
                    icon: "heart.fill",
                    title: "Your Loved Ones",
                    subtitle: "Add and remember those you've lost",
                    action: { currentScreen = .lovedOnes }
                )
                
                SettingsNavigationItem(
                    icon: "moon.fill",
                    title: "Appearance",
                    subtitle: "Light and dark mode settings",
                    action: { currentScreen = .appearance }
                )
                
                SettingsNavigationItem(
                    icon: "trash.fill",
                    title: "Reset Saved Data",
                    subtitle: "Reset your personalized data",
                    action: { currentScreen = .reset }
                )
                
                SettingsNavigationItem(
                    icon: "headphones",
                    title: "App Integrations",
                    subtitle: "Connect music and media apps",
                    action: { currentScreen = .integrations }
                )
            }
            .padding()
            .background(ThemeColors.adaptiveSecondaryBackground)
            
            Spacer()
            
            // Report a Bug button at bottom
            VStack(spacing: 0) {
                Divider()
                
                Button(action: { showingBugReport = true }) {
                    HStack {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .font(.system(size: 16))
                            .foregroundColor(ThemeColors.adaptivePrimary)
                        
                        Text("Report a Bug")
                            .font(.appBody)
                            .foregroundColor(ThemeColors.adaptivePrimary)
                        
                        Spacer()
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                
                // Footer
                VStack(spacing: 8) {
                    Text("✨ This app is in early development. Your feedback helps us create better support tools.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("made with heart, soul, and claude")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ThemeColors.adaptiveAccent)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                }
                .background(ThemeColors.adaptiveSystemBackground)
            }
            .background(ThemeColors.adaptiveSystemBackground)
        }
        .background(ThemeColors.adaptiveSystemBackground)
    }
}

struct SettingsNavigationItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "555879"))
                    .frame(width: 40, height: 40)
                    .background(ThemeColors.adaptiveSecondaryBackground)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.appHeadline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.appBodySmall)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(ThemeColors.adaptiveSystemBackground)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Loved Ones Settings
struct LovedOnesSettingsView: View {
    @Binding var currentScreen: SettingsView.SettingsScreen
    @StateObject private var lovedOnesService = LovedOnesDataService.shared
    @State private var newName = ""
    @State private var newBirthDate = Date()
    @State private var newPassDate = Date()
    @State private var editingPerson: LovedOne? = nil
    @State private var showingEditSheet = false
    
    private let notificationService = NotificationService.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Existing loved ones
                ForEach(lovedOnesService.lovedOnes) { person in
                    LovedOneCard(
                        person: person,
                        onEdit: { editPerson in
                            editingPerson = editPerson
                            showingEditSheet = true
                        },
                        onDelete: { personToDelete in
                            deletePerson(personToDelete)
                        },
                        onToggleUpdate: { updatedPerson in
                            updatePerson(updatedPerson)
                        }
                    )
                }
                
                // Add new loved one
                CardView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Add to My Loved Ones")
                            .font(.system(size: 16, weight: .semibold))
                        
                        TextField("Name (e.g., Mom, Dad, Grandma)", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Birth date")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            DatePicker("Birth date", selection: $newBirthDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                            
                            Text("Date of passing")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            DatePicker("Date of passing", selection: $newPassDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                        
                        PrimaryButton(title: "Add to My Loved Ones") {
                            addNewPerson()
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .padding()
        }
        .background(ThemeColors.adaptiveSystemBackground)
        .sheet(isPresented: $showingEditSheet) {
            if let person = editingPerson {
                EditLovedOneSheet(
                    person: person,
                    onSave: { updatedPerson in
                        updatePerson(updatedPerson)
                        showingEditSheet = false
                        editingPerson = nil
                    },
                    onCancel: {
                        showingEditSheet = false
                        editingPerson = nil
                    }
                )
            }
        }
    }
    
    private func addNewPerson() {
        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        let newPerson = LovedOne(
            name: name,
            birthDate: dateFormatter.string(from: newBirthDate),
            passDate: dateFormatter.string(from: newPassDate),
            birthdayReminders: true,
            memorialReminders: true
        )
        
        lovedOnesService.addLovedOne(newPerson)
        
        // Schedule notifications for the new person (both are enabled by default)
        Task {
            await notificationService.scheduleMemorialReminder(for: newPerson, type: .birthday)
            await notificationService.scheduleMemorialReminder(for: newPerson, type: .memorial)
        }
        
        // Reset form
        newName = ""
        newBirthDate = Date()
        newPassDate = Date()
    }
    
    private func updatePerson(_ updatedPerson: LovedOne) {
        lovedOnesService.updateLovedOne(updatedPerson)
        
        // Handle memorial notifications
        Task {
            // Cancel existing notifications for this person
            notificationService.cancelMemorialReminder(for: updatedPerson, type: .birthday)
            notificationService.cancelMemorialReminder(for: updatedPerson, type: .memorial)
            
            // Schedule new notifications if enabled
            if updatedPerson.birthdayReminders {
                await notificationService.scheduleMemorialReminder(for: updatedPerson, type: .birthday)
            }
            
            if updatedPerson.memorialReminders {
                await notificationService.scheduleMemorialReminder(for: updatedPerson, type: .memorial)
            }
        }
    }
    
    private func deletePerson(_ person: LovedOne) {
        // Cancel all notifications for this person
        notificationService.cancelMemorialReminder(for: person, type: .birthday)
        notificationService.cancelMemorialReminder(for: person, type: .memorial)
        
        lovedOnesService.deleteLovedOne(person)
    }
}


struct LovedOneCard: View {
    let person: LovedOne
    let onEdit: (LovedOne) -> Void
    let onDelete: (LovedOne) -> Void
    let onToggleUpdate: (LovedOne) -> Void
    
    @State private var birthdayReminders: Bool
    @State private var memorialReminders: Bool
    @State private var showingActionSheet = false
    @State private var showingDeleteConfirmation = false
    
    init(person: LovedOne, onEdit: @escaping (LovedOne) -> Void, onDelete: @escaping (LovedOne) -> Void, onToggleUpdate: @escaping (LovedOne) -> Void) {
        self.person = person
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onToggleUpdate = onToggleUpdate
        self._birthdayReminders = State(initialValue: person.birthdayReminders)
        self._memorialReminders = State(initialValue: person.memorialReminders)
    }
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(person.name)
                        .font(.system(size: 18, weight: .semibold))
                    
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
                
                Text("\(person.birthDate) - \(person.passDate)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                VStack(spacing: 10) {
                    HStack {
                        Text("Birthday reminders")
                            .font(.system(size: 14))
                        Spacer()
                        CustomToggle(isOn: $birthdayReminders)
                            .onChange(of: birthdayReminders) { newValue in
                                var updatedPerson = person
                                updatedPerson.birthdayReminders = newValue
                                onToggleUpdate(updatedPerson)
                            }
                    }
                    
                    HStack {
                        Text("Memorial day reminders")
                            .font(.system(size: 14))
                        Spacer()
                        CustomToggle(isOn: $memorialReminders)
                            .onChange(of: memorialReminders) { newValue in
                                var updatedPerson = person
                                updatedPerson.memorialReminders = newValue
                                onToggleUpdate(updatedPerson)
                            }
                    }
                }
            }
        }
        .confirmationDialog("Manage \(person.name)", isPresented: $showingActionSheet, titleVisibility: .visible) {
            Button("Edit Details") {
                onEdit(person)
            }
            
            Button("Delete", role: .destructive) {
                showingDeleteConfirmation = true
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .alert("Delete \(person.name)?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete(person)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove \(person.name) from your loved ones list. This action cannot be undone.")
        }
    }
}

// MARK: - Edit Loved One Sheet
struct EditLovedOneSheet: View {
    let person: LovedOne
    let onSave: (LovedOne) -> Void
    let onCancel: () -> Void
    
    @State private var editedName: String
    @State private var editedBirthDate: Date
    @State private var editedPassDate: Date
    @State private var editedBirthdayReminders: Bool
    @State private var editedMemorialReminders: Bool
    
    init(person: LovedOne, onSave: @escaping (LovedOne) -> Void, onCancel: @escaping () -> Void) {
        self.person = person
        self.onSave = onSave
        self.onCancel = onCancel
        
        // Initialize state with current values
        _editedName = State(initialValue: person.name)
        _editedBirthdayReminders = State(initialValue: person.birthdayReminders)
        _editedMemorialReminders = State(initialValue: person.memorialReminders)
        
        // Parse dates from strings with multiple format attempts
        func parseDate(from dateString: String) -> Date {
            let formatters = [
                DateFormatter.createFormatter(dateStyle: .long),
                DateFormatter.createFormatter(dateFormat: "MMMM d, yyyy"),
                DateFormatter.createFormatter(dateFormat: "MMM d, yyyy"),
                DateFormatter.createFormatter(dateFormat: "M/d/yyyy"),
                DateFormatter.createFormatter(dateFormat: "yyyy-MM-dd")
            ]
            
            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            return Date() // Fallback to current date
        }
        
        _editedBirthDate = State(initialValue: parseDate(from: person.birthDate))
        _editedPassDate = State(initialValue: parseDate(from: person.passDate))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    CardView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Edit Details")
                                .font(.system(size: 20, weight: .semibold))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                TextField("Name", text: $editedName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Birth Date")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                DatePicker("Birth date", selection: $editedBirthDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date of Passing")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                DatePicker("Date of passing", selection: $editedPassDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                            }
                        }
                    }
                    
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Reminder Settings")
                                .font(.system(size: 16, weight: .semibold))
                            
                            HStack {
                                Text("Birthday reminders")
                                    .font(.system(size: 14))
                                Spacer()
                                CustomToggle(isOn: $editedBirthdayReminders)
                            }
                            
                            HStack {
                                Text("Memorial day reminders")
                                    .font(.system(size: 14))
                                Spacer()
                                CustomToggle(isOn: $editedMemorialReminders)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationTitle("Edit \(person.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        var updatedPerson = person
        updatedPerson.name = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedPerson.birthDate = dateFormatter.string(from: editedBirthDate)
        updatedPerson.passDate = dateFormatter.string(from: editedPassDate)
        updatedPerson.birthdayReminders = editedBirthdayReminders
        updatedPerson.memorialReminders = editedMemorialReminders
        
        onSave(updatedPerson)
    }
}

// MARK: - Appearance Settings
struct AppearanceSettingsView: View {
    @Binding var currentScreen: SettingsView.SettingsScreen
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var refreshID = UUID()
    
    var body: some View {
        LazyVStack(spacing: 20) {
            // System theme toggle
            CardView {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Follow System Setting")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Automatically match your device's theme")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    CustomToggle(isOn: $useSystemTheme)
                        .onChange(of: useSystemTheme) { _, newValue in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                // The binding change automatically triggers UI update
                                if newValue {
                                    // When switching to system theme, update to current system setting
                                    isDarkMode = colorScheme == .dark
                                }
                                refreshID = UUID()
                            }
                        }
                }
            }
            
            // Manual theme selection
            CardView {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Theme Mode")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Currently: \(isDarkMode ? "Dark Mode" : "Light Mode")")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    ThemeToggleSwitch(isDarkMode: $isDarkMode, isEnabled: !useSystemTheme)
                        .onChange(of: isDarkMode) { _, _ in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                refreshID = UUID()
                            }
                        }
                }
            }
            .opacity(useSystemTheme ? 0.5 : 1.0)
            .disabled(useSystemTheme)
            
            Spacer()
        }
        .padding()
        .background(ThemeColors.adaptiveSystemBackground)
        .id(refreshID)
    }
}

struct ThemeToggleSwitch: View {
    @Binding var isDarkMode: Bool
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            Text("Light")
                .font(.caption)
                .foregroundColor(isDarkMode ? .secondary : .primary)
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 52, height: 32)
                    .foregroundColor(Color(UIColor.systemGray5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                    )
                
                Circle()
                    .frame(width: 28, height: 28)
                    .foregroundColor(ThemeColors.adaptiveSystemBackground)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .offset(x: isDarkMode ? 10 : -10)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDarkMode)
            }
            .onTapGesture {
                if isEnabled {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isDarkMode.toggle()
                    }
                }
            }
            
            Spacer()
            
            Text("Dark")
                .font(.caption)
                .foregroundColor(isDarkMode ? .primary : .secondary)
                
            Spacer()
        }
    }
}

// MARK: - Reset Settings
struct ResetSettingsView: View {
    @Binding var currentScreen: SettingsView.SettingsScreen
    @State private var showingResetModal = false
    @State private var resetType = ""
    @State private var confirmationText = ""
    @State private var showingResetSuccess = false
    @State private var resetMessage = ""
    @AppStorage("spotifyConnected") private var spotifyConnected = false
    @AppStorage("appleMusicConnected") private var appleMusicConnected = false
    
    var body: some View {
        LazyVStack(spacing: 20) {
            CardView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Reset Saved Data")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Choose what you'd like to reset. This action cannot be undone.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 10) {
                        SecondaryButton(title: "Reset All Reminders") {
                            resetType = "reminders"
                            showingResetModal = true
                        }
                        
                        SecondaryButton(title: "Reset Saved Rituals") {
                            resetType = "rituals"
                            showingResetModal = true
                        }
                        
                        SecondaryButton(title: "Reset Loved Ones List") {
                            resetType = "loved-ones"
                            showingResetModal = true
                        }
                        
                        Button(action: {
                            resetType = "all"
                            showingResetModal = true
                        }) {
                            Text("Reset Everything")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(ThemeColors.adaptiveSystemBackground)
        .sheet(isPresented: $showingResetModal) {
            ResetConfirmationModal(
                resetType: resetType,
                confirmationText: $confirmationText,
                onConfirm: {
                    if confirmationText == "Reset" {
                        performReset(type: resetType)
                        showingResetModal = false
                        confirmationText = ""
                        showingResetSuccess = true
                    }
                },
                onCancel: {
                    showingResetModal = false
                    confirmationText = ""
                }
            )
        }
        .alert("Reset Complete", isPresented: $showingResetSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(resetMessage)
        }
    }
    
    private func performReset(type: String) {
        switch type {
        case "reminders":
            resetReminders()
            resetMessage = "All reminders have been reset to default settings."
            
        case "rituals":
            resetRituals()
            resetMessage = "All saved rituals have been deleted."
            
        case "loved-ones":
            resetLovedOnes()
            resetMessage = "Your loved ones list has been reset."
            
        case "integrations":
            // Music integrations removed
            resetMessage = "Music integrations are no longer available."
            
        case "all":
            resetReminders()
            resetRituals()
            resetLovedOnes()
            // resetIntegrations() - removed
            resetMessage = "All app data has been reset to default settings."
            
        default:
            resetMessage = "Reset operation completed."
        }
    }
    
    private func resetReminders() {
        // Clear the actual reminders data that the RemindersView uses
        UserDefaults.standard.removeObject(forKey: "savedReminders")
        UserDefaults.standard.removeObject(forKey: "reminderTimes")
        UserDefaults.standard.removeObject(forKey: "reminderMessages")
        
        UserDefaults.standard.synchronize()
    }
    
    private func resetRituals() {
        // Clear the actual rituals data that the RitualsView uses
        UserDefaults.standard.removeObject(forKey: "savedRituals")
        UserDefaults.standard.removeObject(forKey: "ritualPhotos")
        UserDefaults.standard.removeObject(forKey: "ritualMusic")
        UserDefaults.standard.removeObject(forKey: "customRitualContent")
        
        UserDefaults.standard.synchronize()
    }
    
    private func resetLovedOnes() {
        // Reset loved ones data using the shared service
        LovedOnesDataService.shared.resetToDefaults()
    }
    
    private func resetIntegrations() {
        // Music integrations have been removed
        // This function is kept for compatibility but does nothing
    }
}

struct ResetConfirmationModal: View {
    let resetType: String
    @Binding var confirmationText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var resetDescription: String {
        switch resetType {
        case "reminders":
            return "This will reset all reminders to default settings. Your custom reminder times and messages will be lost."
        case "rituals":
            return "This will permanently delete all saved rituals including photos, music, and custom content."
        case "loved-ones":
            return "This will remove all loved ones from your list and reset their settings."
        case "integrations":
            return "Music integrations have been removed from the app."
        case "all":
            return "This will completely reset the app to its initial state. All your data and settings will be permanently deleted."
        default:
            return "Are you sure you want to reset \(resetType)? This action cannot be undone."
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm Reset")
                .font(.system(size: 18, weight: .semibold))
            
            Text(resetDescription)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            TextField("Type 'Reset' to confirm", text: $confirmationText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
            
            HStack(spacing: 10) {
                Button("Cancel", action: onCancel)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(ThemeColors.adaptiveSecondaryBackground)
                    .cornerRadius(8)
                
                Button("Reset", action: onConfirm)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(confirmationText != "Reset")
            }
        }
        .padding()
        .frame(width: 320)
        .background(ThemeColors.adaptiveSystemBackground)
        .cornerRadius(12)
    }
}

// MARK: - Integrations Settings (Simplified - No Music Services)
struct IntegrationsSettingsView: View {
    @Binding var currentScreen: SettingsView.SettingsScreen
    
    var body: some View {
        LazyVStack(spacing: 20) {
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Music Integrations")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Music integration features have been temporarily removed. You can still add song names manually when creating rituals.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(ThemeColors.adaptiveSystemBackground)
    }
}

// Empty placeholder views for removed auth screens
struct SpotifyAuthView: View {
    var body: some View {
        EmptyView()
    }
}

struct AppleMusicAuthView: View {
    var body: some View {
        EmptyView()
    }
}

// Placeholder for removed IntegrationItem
struct IntegrationItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isConnected: Bool
    let isAvailable: Bool
    let connectAction: () -> Void
    
    var body: some View {
        EmptyView()
    }
}
// MARK: - Bug Report View
struct BugReportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var issueType = "Bug"
    @State private var description = ""
    @State private var showingSubmitAlert = false
    @State private var showingMailComposer = false
    @State private var showingMailError = false
    
    let issueTypes = [
        ("Bug", "🐛", "Something isn't working as expected"),
        ("Feature Request", "💡", "Suggest a new feature or improvement"),
        ("Performance Issue", "⚡", "App is slow or unresponsive"),
        ("UI/UX Issue", "🎨", "Design or usability concern"),
        ("Other", "📝", "Something else")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("What type of issue are you reporting?")) {
                        Picker("Issue Type", selection: $issueType) {
                            ForEach(issueTypes, id: \.0) { type in
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(type.0)
                                            .font(.system(size: 16, weight: .medium))
                                        Text(type.2)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                } icon: {
                                    Text(type.1)
                                        .font(.system(size: 18))
                                }
                                .tag(type.0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Section(header: Text("Tell us more about the issue")) {
                        TextEditor(text: $description)
                            .frame(height: 120)
                            .onChange(of: description) { _, newValue in
                                if newValue.count > 300 {
                                    description = String(newValue.prefix(300))
                                }
                            }
                        
                        HStack {
                            Text("\(description.count)/300 characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if description.count >= 280 {
                                Text("Almost at limit")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Section {
                        Text("Your feedback helps us improve the app for everyone. We'll review your report and may follow up if we need more information.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(ThemeColors.adaptiveSystemBackground)
                
                // Submit button at bottom
                VStack(spacing: 16) {
                    Divider()
                    
                    Button(action: {
                        submitBugReport()
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Submit Report")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : ThemeColors.adaptivePrimary)
                        .cornerRadius(12)
                    }
                    .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(ThemeColors.adaptiveSystemBackground)
            }
            .navigationTitle("Report Issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Report Submitted", isPresented: $showingSubmitAlert) {
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Thank you for your feedback! We'll review it and get back to you if needed.")
            }
            .alert("Email Not Available", isPresented: $showingMailError) {
                Button("OK") { }
            } message: {
                Text("Email is not configured on this device. Please contact support at \(AppConstants.supportEmail)")
            }
            .sheet(isPresented: $showingMailComposer) {
                MailComposerView(
                    recipients: [AppConstants.supportEmail],
                    subject: "Light After Loss - \(issueType) Report",
                    messageBody: createEmailBody(),
                    onResult: { result in
                        showingMailComposer = false
                        if result == .sent {
                            showingSubmitAlert = true
                        }
                    }
                )
            }
        }
    }
    
    private func submitBugReport() {
        if MFMailComposeViewController.canSendMail() {
            showingMailComposer = true
        } else {
            showingMailError = true
        }
    }
    
    private func createEmailBody() -> String {
        let deviceInfo = """
        
        ---
        Device Information:
        App Version: 1.0
        iOS Version: \(UIDevice.current.systemVersion)
        Device Model: \(UIDevice.current.model)
        
        Issue Type: \(issueType)
        Description: \(description)
        """
        return deviceInfo
    }
}

// MARK: - Mail Composer
struct MailComposerView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let messageBody: String
    let onResult: (MFMailComposeResult) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(messageBody, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onResult: onResult)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onResult: (MFMailComposeResult) -> Void
        
        init(onResult: @escaping (MFMailComposeResult) -> Void) {
            self.onResult = onResult
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            onResult(result)
        }
    }
}

#Preview {
    SettingsView()
}
