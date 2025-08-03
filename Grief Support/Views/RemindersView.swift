//
//  RemindersView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import Foundation

struct RemindersView: View {
    @State private var reminders: [Reminder] = []
    @State private var showingAddReminder = false
    @State private var showingCustomizeTimes = false
    @State private var editingReminder: Reminder? = nil
    @State private var showingEditSheet = false
    
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
                        LazyVStack(spacing: 0) {
                            ForEach(reminders.indices, id: \.self) { index in
                                ReminderRow(
                                    reminder: $reminders[index],
                                    onEdit: { reminder in
                                        editingReminder = reminder
                                        showingEditSheet = true
                                    },
                                    onDelete: { reminder in
                                        deleteReminder(reminder)
                                    }
                                )
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                
                                if index < reminders.count - 1 {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .background(ThemeColors.adaptiveCardBackground)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    PrimaryButton(title: "+ Add New Reminder") {
                        showingAddReminder = true
                    }
                    
                    SecondaryButton(title: "Customize Times") {
                        showingCustomizeTimes = true
                    }
                }
                .padding()
                .padding(.top, 100)
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(onReminderAdded: { newReminder in
                reminders.append(newReminder)
                saveReminders() // Save immediately
                showingAddReminder = false
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
        if let index = reminders.firstIndex(where: { $0.id == updatedReminder.id }) {
            reminders[index] = updatedReminder
            saveReminders()
        }
    }
    
    private func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
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
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(reminder.time)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(ThemeColors.adaptivePrimary)
                
                Text(reminder.message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            CustomToggle(isOn: $reminder.isEnabled)
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
            
            Button(action: {
                onEdit(reminder)
            }) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
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
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTime = Date()
    @State private var customMessage = ""
    
    let presetMessages = [
        "You are stronger than you know",
        "It's okay to take things one moment at a time",
        "Your feelings are valid",
        "Remember to be gentle with yourself",
        "You don't have to face this alone"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    VStack(spacing: 0) {
                Section(header: Text("Time")) {
                    DatePicker("Reminder Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                }
                
                Section(header: Text("Message")) {
                    TextField("Custom message", text: $customMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Or choose a preset message")) {
                    ForEach(presetMessages, id: \.self) { message in
                        Button(action: {
                            customMessage = message
                        }) {
                            Text(message)
                                .foregroundColor(.primary)
                                .padding(.vertical, 4)
                        }
                    }
                }
                    }
                    .padding()
                    .background(ThemeColors.adaptiveCardBackground)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .padding()
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                        let timeString = formatter.string(from: selectedTime)
                        
                        let newReminder = Reminder(
                            time: timeString,
                            message: customMessage.isEmpty ? presetMessages[0] : customMessage,
                            isEnabled: true
                        )
                        onReminderAdded(newReminder)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
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
