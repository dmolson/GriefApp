//
//  RemindersView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI

struct RemindersView: View {
    @State private var reminders: [Reminder] = [
        Reminder(time: "8:00 AM", message: "Each day is a step forward in your healing journey.", isEnabled: true),
        Reminder(time: "12:00 PM", message: "Your loved one's memory lives on through your love.", isEnabled: true),
        Reminder(time: "6:00 PM", message: "It's okay to feel whatever you're feeling today.", isEnabled: true)
    ]
    @State private var showingAddReminder = false
    @State private var showingCustomizeTimes = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeaderView(title: "Daily Reminders")
                    
                    CardView {
                        VStack(spacing: 0) {
                            ForEach(reminders.indices, id: \.self) { index in
                                ReminderRow(reminder: $reminders[index])
                                
                                if index < reminders.count - 1 {
                                    Divider()
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                    
                    PrimaryButton(title: "+ Add New Reminder") {
                        showingAddReminder = true
                    }
                    
                    SecondaryButton(title: "Customize Times") {
                        showingCustomizeTimes = true
                    }
                }
                .padding()
                .padding(.top, 144) // Account for header height
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(reminders: $reminders)
        }
        .sheet(isPresented: $showingCustomizeTimes) {
            CustomizeTimesView(reminders: $reminders)
        }
    }
}

struct Reminder: Identifiable {
    let id = UUID()
    var time: String
    var message: String
    var isEnabled: Bool
}

struct ReminderRow: View {
    @Binding var reminder: Reminder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(reminder.time)
                    .font(.appHeadline)
                    .foregroundColor(ThemeColors.adaptivePrimary)
                
                Text(reminder.message)
                    .font(.appBodySmall)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            CustomToggle(isOn: $reminder.isEnabled)
        }
        .padding(.vertical, 8)
    }
}

struct AddReminderView: View {
    @Binding var reminders: [Reminder]
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
            Form {
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
                        reminders.append(newReminder)
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
                VStack(spacing: 20) {
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
            .background(Color(UIColor.systemBackground))
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
                    .background(Color(UIColor.secondarySystemBackground))
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