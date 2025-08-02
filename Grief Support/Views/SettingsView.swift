//
//  SettingsView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentScreen: SettingsScreen = .main
    @State private var showingResetConfirmation = false
    @State private var resetType = ""
    
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
                                .foregroundColor(.white)
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(navigationTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(Color(hex: "555879"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
            .background(Color(hex: "F4EFE8"))
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
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
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "555879"))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Loved Ones Settings
struct LovedOnesSettingsView: View {
    @Binding var currentScreen: SettingsView.SettingsScreen
    @State private var lovedOnes: [LovedOne] = [
        LovedOne(name: "Matthew", birthDate: "March 15, 1985", passDate: "August 12, 2024", birthdayReminders: true, memorialReminders: true)
    ]
    @State private var newName = ""
    @State private var newBirthDate = Date()
    @State private var newPassDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Existing loved ones
                ForEach(lovedOnes) { person in
                    LovedOneCard(person: person)
                }
                
                // Add new loved one
                CardView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Add Someone Special")
                            .font(.system(size: 16, weight: .semibold))
                        
                        TextField("Name (e.g., Matthew, Mom, Smudge)", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack(spacing: 10) {
                            DatePicker("Birth date", selection: $newBirthDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                            
                            DatePicker("Date of passing", selection: $newPassDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                        
                        PrimaryButton(title: "Add to My Loved Ones") {
                            // TODO: Add loved one
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct LovedOne: Identifiable {
    let id = UUID()
    let name: String
    let birthDate: String
    let passDate: String
    var birthdayReminders: Bool
    var memorialReminders: Bool
}

struct LovedOneCard: View {
    let person: LovedOne
    @State private var birthdayReminders: Bool
    @State private var memorialReminders: Bool
    
    init(person: LovedOne) {
        self.person = person
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
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("\(person.birthDate) - \(person.passDate)")
                    .font(.custom("CormorantGaramond-Regular", size: 14))
                    .foregroundColor(.secondary)
                
                VStack(spacing: 10) {
                    HStack {
                        Text("Birthday reminders")
                            .font(.system(size: 14))
                        Spacer()
                        CustomToggle(isOn: $birthdayReminders)
                    }
                    
                    HStack {
                        Text("Memorial day reminders")
                            .font(.system(size: 14))
                        Spacer()
                        CustomToggle(isOn: $memorialReminders)
                    }
                }
            }
        }
    }
}

// MARK: - Appearance Settings
struct AppearanceSettingsView: View {
    @Binding var currentScreen: SettingsView.SettingsScreen
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        VStack(spacing: 20) {
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
                }
            }
            .opacity(useSystemTheme ? 0.5 : 1.0)
            .disabled(useSystemTheme)
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct ThemeToggleSwitch: View {
    @Binding var isDarkMode: Bool
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Text("Light")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isDarkMode ? .secondary : .primary)
            
            Spacer()
            
            Text("Dark")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isDarkMode ? .primary : .secondary)
        }
        .padding(.horizontal, 12)
        .frame(width: 100, height: 40)
        .background(Color(hex: "F0EBE2"))
        .overlay(
            HStack {
                if isDarkMode {
                    Spacer()
                }
                
                Circle()
                    .fill(Color(hex: "555879"))
                    .frame(width: 36, height: 36)
                    .animation(.spring(), value: isDarkMode)
                
                if !isDarkMode {
                    Spacer()
                }
            }
            .padding(2)
        )
        .cornerRadius(20)
        .onTapGesture {
            if isEnabled {
                isDarkMode.toggle()
            }
        }
    }
}

// MARK: - Reset Settings
struct ResetSettingsView: View {
    @Binding var currentScreen: SettingsView.SettingsScreen
    @State private var showingResetModal = false
    @State private var resetType = ""
    @State private var confirmationText = ""
    
    var body: some View {
        VStack(spacing: 20) {
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
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showingResetModal) {
            ResetConfirmationModal(
                resetType: resetType,
                confirmationText: $confirmationText,
                onConfirm: {
                    if confirmationText == "Reset" {
                        // TODO: Perform reset
                        showingResetModal = false
                        confirmationText = ""
                    }
                },
                onCancel: {
                    showingResetModal = false
                    confirmationText = ""
                }
            )
        }
    }
}

struct ResetConfirmationModal: View {
    let resetType: String
    @Binding var confirmationText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm Reset")
                .font(.system(size: 18, weight: .semibold))
            
            Text("Are you sure you want to reset \(resetType)? This action cannot be undone.")
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
                    .background(Color(UIColor.secondarySystemBackground))
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
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Integrations Settings
struct IntegrationsSettingsView: View {
    @Binding var currentScreen: SettingsView.SettingsScreen
    @State private var spotifyConnected = false
    @State private var appleMusicConnected = true
    
    var body: some View {
        VStack(spacing: 20) {
            IntegrationItem(
                icon: "music.note",
                iconColor: Color(hex: "1DB954"),
                title: "Spotify",
                subtitle: "Play music in your rituals",
                isConnected: $spotifyConnected
            )
            
            IntegrationItem(
                icon: "music.note.list",
                iconColor: Color(hex: "FA243C"),
                title: "Apple Music",
                subtitle: "Access your music library",
                isConnected: $appleMusicConnected
            )
            
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("How Integrations Work")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("When you connect music apps, you can add songs to your grief rituals. Music plays within our app - we never access your personal playlists or listening history.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct IntegrationItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isConnected: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(iconColor)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { isConnected.toggle() }) {
                Text(isConnected ? "Connected" : "Connect")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isConnected ? Color.green : Color(hex: "555879"))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    SettingsView()
}