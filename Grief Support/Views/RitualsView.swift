//
//  RitualsView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import PhotosUI

struct RitualsView: View {
    @State private var selectedRitualType: RitualType?
    @State private var selectedPerson = ""
    @State private var customIdeas = ""
    @State private var connectionPrompts = ""
    @State private var reflectionPrompts = ""
    @State private var itemsText = ""
    @State private var selectedImages: [UIImage] = []
    @State private var selectedPresetImages: Set<String> = ["flower"]
    @State private var showingImagePicker = false
    @State private var showingLovedOnesSettings = false
    @State private var selectedPersonFilter = "all"
    
    let lovedOnes = ["All", "Matthew", "Mom", "Smudge"] // This would come from data persistence
    
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Top buttons row
                    HStack(spacing: 12) {
                        PrimaryButton(title: "Create") {
                            // TODO: Create new ritual
                        }
                        .frame(maxWidth: .infinity)
                        
                        ForEach(lovedOnes.dropFirst(), id: \.self) { person in
                            Button(action: {
                                selectedPersonFilter = person.lowercased()
                            }) {
                                Text(person)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedPersonFilter == person.lowercased() ? .white : Color(hex: "555879"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedPersonFilter == person.lowercased() ? Color(hex: "555879") : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(hex: "555879"), lineWidth: 2)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                        
                        Button(action: {
                            selectedPersonFilter = "all"
                        }) {
                            Text("All")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedPersonFilter == "all" ? .white : Color(hex: "555879"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedPersonFilter == "all" ? Color(hex: "555879") : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "555879"), lineWidth: 2)
                                )
                                .cornerRadius(8)
                        }
                    }
                    
                    SectionHeaderView(title: "Create Your Ritual")
                    
                    // Ritual Type Selection
                    CardView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Choose Ritual Type")
                                .font(.system(size: 16, weight: .semibold))
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(RitualType.allCases, id: \.self) { type in
                                    RitualTypeCard(
                                        type: type,
                                        isSelected: selectedRitualType == type,
                                        action: { selectedRitualType = type }
                                    )
                                }
                            }
                        }
                    }
                    
                    // Person Selection (for birthday/anniversary)
                    if selectedRitualType == .birthday || selectedRitualType == .anniversary {
                        CardView {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Select Your Loved One")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Picker("Choose someone", selection: $selectedPerson) {
                                    Text("Choose someone...").tag("")
                                    Text("Matthew").tag("matthew")
                                    Text("Mom").tag("mom")
                                    Text("Smudge").tag("smudge")
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(8)
                                
                                // Notification Banner
                                if !selectedPerson.isEmpty {
                                    NotificationBanner(
                                        person: selectedPerson,
                                        ritualType: selectedRitualType!,
                                        onTap: { showingLovedOnesSettings = true }
                                    )
                                }
                            }
                        }
                    }
                    
                    // Ritual-specific content
                    if let selectedType = selectedRitualType {
                        switch selectedType {
                        case .connection:
                            ConnectionRitualContent(
                                customIdeas: $customIdeas,
                                connectionPrompts: $connectionPrompts,
                                itemsText: $itemsText
                            )
                        case .reflection:
                            ReflectionRitualContent(
                                customIdeas: $customIdeas,
                                reflectionPrompts: $reflectionPrompts,
                                itemsText: $itemsText
                            )
                        case .birthday, .anniversary:
                            BirthdayAnniversaryRitualContent(customIdeas: $customIdeas)
                        }
                        
                        // Upload Photos
                        SectionHeaderView(title: "Upload Photos")
                        
                        Button(action: { showingImagePicker = true }) {
                            VStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                                Text("Tap to add photos from your device")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(Color(UIColor.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    .foregroundColor(Color(hex: "DED3C4"))
                            )
                        }
                        
                        // Preset Images
                        SectionHeaderView(title: "Preset Images")
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            PresetImageView(icon: "flame.fill", name: "candle", isSelected: selectedPresetImages.contains("candle")) {
                                togglePresetImage("candle")
                            }
                            PresetImageView(icon: "leaf.fill", name: "flower", isSelected: selectedPresetImages.contains("flower")) {
                                togglePresetImage("flower")
                            }
                            PresetImageView(icon: "hands.and.sparkles.fill", name: "praying", isSelected: selectedPresetImages.contains("praying")) {
                                togglePresetImage("praying")
                            }
                            PresetImageView(icon: "butterfly.fill", name: "butterfly", isSelected: selectedPresetImages.contains("butterfly")) {
                                togglePresetImage("butterfly")
                            }
                            PresetImageView(icon: "star.fill", name: "star", isSelected: selectedPresetImages.contains("star")) {
                                togglePresetImage("star")
                            }
                            PresetImageView(icon: "sun.max.fill", name: "sunrise", isSelected: selectedPresetImages.contains("sunrise")) {
                                togglePresetImage("sunrise")
                            }
                            PresetImageView(icon: "heart.fill", name: "heart", isSelected: selectedPresetImages.contains("heart")) {
                                togglePresetImage("heart")
                            }
                        }
                        
                        // Starting Points (moved to bottom)
                        SectionHeaderView(title: "Starting Points")
                        
                        CardView {
                            VStack(spacing: 8) {
                                StartingPointView(
                                    title: "Choose a Place",
                                    description: "Find a safe, comfortable space where you feel okay showing emotions"
                                )
                                StartingPointView(
                                    title: "Gather Items", 
                                    description: "Objects that remind you of your loved one or bring comfort"
                                )
                                StartingPointView(
                                    title: "Include Photos",
                                    description: "Cherished memories you'd like to have present"
                                )
                            }
                        }
                        
                        PrimaryButton(title: selectedRitualType != nil ? "Save \(selectedRitualType!.rawValue)" : "Save My Ritual") {
                            // TODO: Save ritual
                        }
                        
                        SecondaryButton(title: "Browse Templates") {
                            // TODO: Show templates
                        }
                    }
                }
                .padding()
                .padding(.top, 124) // Account for header height
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(images: $selectedImages)
        }
        .sheet(isPresented: $showingLovedOnesSettings) {
            SettingsView()
        }
    }
    
    private func togglePresetImage(_ name: String) {
        if selectedPresetImages.contains(name) {
            selectedPresetImages.remove(name)
        } else {
            selectedPresetImages.insert(name)
        }
    }
}

// MARK: - Connection Ritual Content
struct ConnectionRitualContent: View {
    @Binding var customIdeas: String
    @Binding var connectionPrompts: String
    @Binding var itemsText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Connection Prompts
            CardView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Connection Ideas")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Here are some gentle ways to connect with your loved one. Choose what feels right for you today:")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "Write them a letter about what's happening in your life")
                        BulletPoint(text: "Talk to them out loud about your day or your feelings")
                        BulletPoint(text: "Sing a song that reminds you of them")
                        BulletPoint(text: "Share a memory you love about them")
                        BulletPoint(text: "Ask them for guidance and sit quietly to listen")
                    }
                    
                    TextEditor(text: $connectionPrompts)
                        .frame(height: 80)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            Group {
                                if connectionPrompts.isEmpty {
                                    Text("What would you like to say or ask?")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
            }
            
            // Items section
            CardView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Items")
                        .font(.system(size: 16, weight: .semibold))
                    
                    TextEditor(text: $itemsText)
                        .frame(height: 80)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            Group {
                                if itemsText.isEmpty {
                                    Text("What are objects that remind you of your loved one?")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
            }
            
            // Custom Ideas
            CardView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Custom Ritual Ideas")
                        .font(.system(size: 16, weight: .semibold))
                    
                    TextEditor(text: $customIdeas)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            Group {
                                if customIdeas.isEmpty {
                                    Text("Add your own ideas for this connection ritual")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
            }
        }
    }
}

// MARK: - Reflection Ritual Content
struct ReflectionRitualContent: View {
    @Binding var customIdeas: String
    @Binding var reflectionPrompts: String
    @Binding var itemsText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Reflection Prompts
            CardView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Reflection Ideas")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Take time to honor your healing journey. These prompts can help you connect with yourself:")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "What am I feeling right now, and that's okay")
                        BulletPoint(text: "What do I need in this moment to feel supported?")
                        BulletPoint(text: "What am I avoiding that might help me heal?")
                        BulletPoint(text: "What would my loved one want me to know right now?")
                        BulletPoint(text: "What songs, resources, or support do I want to seek out?")
                    }
                    
                    TextEditor(text: $reflectionPrompts)
                        .frame(height: 80)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            Group {
                                if reflectionPrompts.isEmpty {
                                    Text("What thoughts or feelings want your attention?")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
            }
            
            // Items section
            CardView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Items")
                        .font(.system(size: 16, weight: .semibold))
                    
                    TextEditor(text: $itemsText)
                        .frame(height: 80)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            Group {
                                if itemsText.isEmpty {
                                    Text("What are objects that remind you of your loved one?")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
            }
            
            // Custom Ideas
            CardView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Custom Ritual Ideas")
                        .font(.system(size: 16, weight: .semibold))
                    
                    TextEditor(text: $customIdeas)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            Group {
                                if customIdeas.isEmpty {
                                    Text("Add your own ideas for this reflection ritual")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
            }
        }
    }
}

// MARK: - Birthday/Anniversary Ritual Content
struct BirthdayAnniversaryRitualContent: View {
    @Binding var customIdeas: String
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Custom Ritual Ideas")
                    .font(.system(size: 16, weight: .semibold))
                
                TextEditor(text: $customIdeas)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .overlay(
                        Group {
                            if customIdeas.isEmpty {
                                Text("e.g. Eating her favorite cake, listen to his favorite songs, FaceTime with our family, 5K race")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
            }
        }
    }
}

// MARK: - Supporting Views
struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(Color(hex: "555879"))
                .font(.system(size: 14, weight: .semibold))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}

struct StartingPointView: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color(hex: "555879").opacity(0.2))
                .frame(width: 8, height: 8)
                .offset(y: 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct RitualTypeCard: View {
    let type: RitualsView.RitualType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color(hex: "555879") : .gray)
                
                Text(type.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(isSelected ? Color(hex: "DED3C4") : Color(hex: "F0EBE2"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "555879") : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct PresetImageView: View {
    let icon: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? Color(hex: "555879") : .gray)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(Color(hex: "F0EBE2"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(hex: "555879") : Color.clear, lineWidth: 2)
                )
        }
    }
}

struct NotificationBanner: View {
    let person: String
    let ritualType: RitualsView.RitualType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 16))
                
                Text("Turn back on notifications in Your Loved Ones to receive ritual reminders")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
            }
            .padding()
            .foregroundColor(Color(hex: "856404"))
            .background(Color(hex: "FFF3CD"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "FFC107"), lineWidth: 1)
            )
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0
        
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
            parent.presentationMode.wrappedValue.dismiss()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RitualsView()
}