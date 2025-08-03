//
//  RemindersView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import Foundation
import UserNotifications

struct RemindersView: View {
    @State private var reminders: [Reminder] = []
    @State private var showingAddReminder = false
    @State private var showingCustomizeTimes = false
    @State private var editingReminder: Reminder? = nil
    @State private var showingEditSheet = false
    @State private var hasNotificationPermission = false
    
    private let notificationService = NotificationService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    SectionHeaderView(title: "Daily Reminders")
                    
                    if reminders.isEmpty {
                        // Empty state
                        CardView {
                            VStack(spacing: 16) {
                                Image(systemName: "bell.slash")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                
                                Text("No Reminders")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Add your first reminder to get gentle daily support")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 20)
                        }
                    } else {
                        Text("Swipe left on any reminder to edit or delete")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    
                    if !reminders.isEmpty {
                        List {
                            ForEach(reminders.indices, id: \.self) { index in
                                ReminderRow(
                                    reminder: $reminders[index],
                                    onEdit: { reminder in
                                        editingReminder = reminder
                                        showingEditSheet = true
                                    },
                                    onDelete: { reminder in
                                        deleteReminder(reminder)
                                    },
                                    onToggle: { reminder in
                                        handleReminderToggle(reminder)
                                    }
                                )
                                .listRowBackground(ThemeColors.adaptiveCardBackground)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .background(ThemeColors.adaptiveCardBackground)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .frame(height: CGFloat(reminders.count * 80)) // Dynamic height based on content
                    }
                    
                    PrimaryButton(title: "+ Add New Reminder") {
                        showingAddReminder = true
                    }
                    
                    SecondaryButton(title: "Customize Times") {
                        showingCustomizeTimes = true
                    }
                }
                .padding()
                .padding(.top, 144)
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(onReminderAdded: { newReminder in
                DispatchQueue.main.async {
                    reminders.append(newReminder)
                    saveReminders() // Save immediately
                    scheduleReminderNotification(newReminder) // Schedule notification
                    showingAddReminder = false // Ensure sheet closes
                }
            })
        }
        .sheet(isPresented: $showingCustomizeTimes) {
            CustomizeTimesView(reminders: $reminders)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let reminder = editingReminder {
                EditReminderView(
                    reminder: reminder,
                    onSave: { updatedReminder in
                        updateReminder(updatedReminder)
                        showingEditSheet = false
                        editingReminder = nil
                    },
                    onCancel: {
                        showingEditSheet = false
                        editingReminder = nil
                    }
                )
            }
        }
        .onAppear {
            loadReminders()
            checkNotificationPermission()
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "savedReminders"),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = decoded
        } else {
            // Initialize with empty array - users start fresh
            reminders = []
        }
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: "savedReminders")
        }
    }
    
    private func updateReminder(_ updatedReminder: Reminder) {
        DispatchQueue.main.async {
            if let index = reminders.firstIndex(where: { $0.id == updatedReminder.id }) {
                let oldReminder = reminders[index]
                
                // Cancel old notification
                notificationService.cancelReminder(oldReminder)
                
                // Update reminder
                reminders[index] = updatedReminder
                saveReminders()
                
                // Schedule new notification if enabled
                if updatedReminder.isEnabled {
                    scheduleReminderNotification(updatedReminder)
                }
            }
        }
    }
    
    private func deleteReminder(_ reminder: Reminder) {
        // Cancel the notification first
        notificationService.cancelReminder(reminder)
        
        DispatchQueue.main.async {
            reminders.removeAll { $0.id == reminder.id }
            saveReminders()
        }
    }
    
    private func checkNotificationPermission() {
        Task {
            let status = await notificationService.checkNotificationPermission()
            await MainActor.run {
                hasNotificationPermission = (status == .authorized)
            }
            
            // If we don't have permission, request it
            if status == .notDetermined {
                let granted = await notificationService.requestNotificationPermission()
                await MainActor.run {
                    hasNotificationPermission = granted
                }
            }
            
            // Schedule all enabled reminders if we have permission
            if hasNotificationPermission {
                await notificationService.rescheduleAllReminders(reminders)
            }
        }
    }
    
    private func scheduleReminderNotification(_ reminder: Reminder) {
        guard hasNotificationPermission else { return }
        
        Task {
            await notificationService.scheduleReminder(reminder)
        }
    }
    
    private func handleReminderToggle(_ reminder: Reminder) {
        // Save the updated state
        saveReminders()
        
        // Handle notification scheduling
        if reminder.isEnabled {
            scheduleReminderNotification(reminder)
        } else {
            notificationService.cancelReminder(reminder)
        }
    }
}

struct Reminder: Identifiable, Codable, Equatable {
    let id: UUID
    var time: String
    var message: String
    var isEnabled: Bool
    
    init(time: String, message: String, isEnabled: Bool) {
        self.id = UUID()
        self.time = time
        self.message = message
        self.isEnabled = isEnabled
    }
    
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        lhs.id == rhs.id
    }
}

struct ReminderRow: View {
    @Binding var reminder: Reminder
    let onEdit: (Reminder) -> Void
    let onDelete: (Reminder) -> Void
    let onToggle: (Reminder) -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(reminder.time)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(ThemeColors.adaptivePrimary)
                
                Text(reminder.message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                CustomToggle(isOn: $reminder.isEnabled)
                    .onChange(of: reminder.isEnabled) { _, newValue in
                        onToggle(reminder)
                    }
                
                if !reminder.isEnabled {
                    Text("Paused")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Label("Delete", systemImage: "trash.fill")
            }
            .tint(.red)
            
            Button(action: {
                onEdit(reminder)
            }) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(ThemeColors.adaptivePrimary)
        }
        .alert("Delete Reminder?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete(reminder)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove the \(reminder.time) reminder. This action cannot be undone.")
        }
    }
}

struct EditReminderView: View {
    let reminder: Reminder
    let onSave: (Reminder) -> Void
    let onCancel: () -> Void
    
    @State private var editedTime: Date
    @State private var editedMessage: String
    @State private var editedIsEnabled: Bool
    
    let presetMessages = [
        "You are stronger than you know",
        "It's okay to take things one moment at a time",
        "Your feelings are valid",
        "Remember to be gentle with yourself",
        "You don't have to face this alone",
        "Each day is a step forward in your healing journey",
        "Your loved one's memory lives on through your love",
        "It's okay to feel whatever you're feeling today"
    ]
    
    init(reminder: Reminder, onSave: @escaping (Reminder) -> Void, onCancel: @escaping () -> Void) {
        self.reminder = reminder
        self.onSave = onSave
        self.onCancel = onCancel
        
        _editedMessage = State(initialValue: reminder.message)
        _editedIsEnabled = State(initialValue: reminder.isEnabled)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        if let time = formatter.date(from: reminder.time) {
            _editedTime = State(initialValue: time)
        } else {
            _editedTime = State(initialValue: Date())
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    CardView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Edit Reminder")
                                .font(.system(size: 20, weight: .semibold))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Time")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                DatePicker("Reminder Time", selection: $editedTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Message")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                TextEditor(text: $editedMessage)
                                    .frame(height: 80)
                                    .padding(8)
                                    .background(ThemeColors.adaptiveSecondaryBackground)
                                    .cornerRadius(8)
                            }
                            
                            HStack {
                                Text("Reminder Enabled")
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                                CustomToggle(isOn: $editedIsEnabled)
                            }
                        }
                    }
                    
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Message Options")
                                .font(.system(size: 16, weight: .semibold))
                            
                            LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                                ForEach(presetMessages, id: \.self) { message in
                                    Button(action: {
                                        editedMessage = message
                                    }) {
                                        HStack {
                                            Text(message)
                                                .font(.system(size: 14))
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            if editedMessage == message {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(ThemeColors.adaptivePrimary)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(editedMessage == message ? ThemeColors.adaptivePrimary.opacity(0.1) : ThemeColors.adaptiveTertiaryBackground)
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationTitle("Edit Reminder")
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
                    .disabled(editedMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        var updatedReminder = reminder
        updatedReminder.time = formatter.string(from: editedTime)
        updatedReminder.message = editedMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedReminder.isEnabled = editedIsEnabled
        
        onSave(updatedReminder)
    }
}

struct AddReminderView: View {
    let onReminderAdded: (Reminder) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTime = Date()
    @State private var customMessage = ""
    @State private var selectedPresetMessage = ""
    
    let presetMessages = [
        "You are stronger than you know",
        "It's okay to take things one moment at a time",
        "Your feelings are valid",
        "Remember to be gentle with yourself",
        "You don't have to face this alone",
        "Each day is a step forward in your healing journey",
        "Your loved one's memory lives on through your love",
        "It's okay to feel whatever you're feeling today"
    ]
    
    var finalMessage: String {
        if !customMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return customMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if !selectedPresetMessage.isEmpty {
            return selectedPresetMessage
        } else {
            return presetMessages[0]
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Time Selection Card
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Reminder Time")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                        }
                    }
                    
                    // Custom Message Card
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Custom Message")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Write your own personal reminder message")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $customMessage)
                                .frame(height: 80)
                                .padding(12)
                                .background(ThemeColors.adaptiveSecondaryBackground)
                                .cornerRadius(8)
                                .onChange(of: customMessage) { _, _ in
                                    if !customMessage.isEmpty {
                                        selectedPresetMessage = ""
                                    }
                                }
                            
                            if !customMessage.isEmpty {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Using custom message")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // Preset Messages Card
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Message Options")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Tap any message below to use it as your reminder")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(presetMessages, id: \.self) { message in
                                    Button(action: {
                                        selectedPresetMessage = message
                                        customMessage = ""
                                    }) {
                                        HStack {
                                            Text(message)
                                                .font(.system(size: 14))
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            if selectedPresetMessage == message {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(ThemeColors.adaptivePrimary)
                                            }
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .background(selectedPresetMessage == message ? ThemeColors.adaptivePrimary.opacity(0.1) : ThemeColors.adaptiveSecondaryBackground)
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    
                    // Preview Card
                    if !finalMessage.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Preview")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(timeString(from: selectedTime))
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(ThemeColors.adaptivePrimary)
                                        
                                        Text(finalMessage)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(ThemeColors.adaptivePrimary)
                                }
                                .padding()
                                .background(ThemeColors.adaptiveSecondaryBackground.opacity(0.5))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReminder()
                    }
                    .disabled(finalMessage.isEmpty)
                }
            }
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveReminder() {
        let newReminder = Reminder(
            time: timeString(from: selectedTime),
            message: finalMessage,
            isEnabled: true
        )
        onReminderAdded(newReminder)
        dismiss()
    }
}

struct CustomizeTimesView: View {
    @Binding var reminders: [Reminder]
    @Environment(\.presentationMode) var presentationMode
    @State private var tempReminders: [Reminder] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    SectionHeaderView(title: "Customize Reminder Times")
                        .padding(.horizontal)
                    
                    Text("Adjust the times for your existing reminders. Your messages will stay the same.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    CardView {
                        VStack(spacing: 0) {
                            ForEach(tempReminders.indices, id: \.self) { index in
                                CustomizeTimeRow(reminder: $tempReminders[index])
                                
                                if index < tempReminders.count - 1 {
                                    Divider()
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationTitle("Customize Times")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(ThemeColors.adaptivePrimaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        reminders = tempReminders
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(ThemeColors.adaptivePrimaryText)
                }
            }
            .toolbarBackground(ThemeColors.adaptivePrimaryBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                tempReminders = reminders
            }
        }
    }
}

struct CustomizeTimeRow: View {
    @Binding var reminder: Reminder
    @State private var selectedTime = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current: \(reminder.time)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeColors.adaptivePrimary)
                    
                    Text(reminder.message)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text(timeString(from: selectedTime))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColors.adaptivePrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(ThemeColors.adaptiveSecondaryBackground)
                    .cornerRadius(8)
            }
            
            DatePicker("New Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .onChange(of: selectedTime) { _, newTime in
                    reminder.time = timeString(from: newTime)
                }
        }
        .padding(.vertical, 8)
        .onAppear {
            selectedTime = timeFromString(reminder.time) ?? Date()
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func timeFromString(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.date(from: timeString)
    }
}

#Preview {
    RemindersView()
}
