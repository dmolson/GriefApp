//
//  CommonComponents.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(ThemeColors.adaptiveCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Section Header
struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.appHeadline)
            .foregroundColor(.primary)
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appHeadline)
                .foregroundColor(ThemeColors.adaptivePrimaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ThemeColors.adaptivePrimaryBackground)
                .cornerRadius(8)
        }
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appHeadline)
                .foregroundColor(ThemeColors.adaptivePrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ThemeColors.adaptivePrimary, lineWidth: 2)
                )
        }
    }
}

// MARK: - Toggle Switch
struct CustomToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle("", isOn: $isOn)
            .toggleStyle(SwitchToggleStyle(tint: ThemeColors.adaptiveAccent))
            .labelsHidden()
    }
}

// MARK: - Day Selection View
struct DaySelectionView: View {
    @Binding var selectedDays: Set<Int>
    
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    private let fullDayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Days")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                ForEach(0..<7) { dayIndex in
                    DayButton(
                        label: dayLabels[dayIndex],
                        isSelected: selectedDays.contains(dayIndex),
                        action: {
                            toggleDay(dayIndex)
                        }
                    )
                }
            }
            
            // Display selected days summary
            Text(selectedDaysText)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .italic()
        }
    }
    
    private func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            // Don't allow removing if it's the last selected day
            if selectedDays.count > 1 {
                selectedDays.remove(day)
            }
        } else {
            selectedDays.insert(day)
        }
    }
    
    private var selectedDaysText: String {
        if selectedDays.count == 7 {
            return "Reminder will be sent every day"
        } else if selectedDays.count == 0 {
            return "Please select at least one day"
        } else {
            let sortedDays = selectedDays.sorted()
            let dayNames = sortedDays.map { fullDayNames[$0] }
            
            // Check for weekdays/weekends patterns
            let weekdays = Set([1, 2, 3, 4, 5])
            let weekends = Set([0, 6])
            
            if selectedDays == weekdays {
                return "Reminder will be sent on weekdays"
            } else if selectedDays == weekends {
                return "Reminder will be sent on weekends"
            } else if dayNames.count <= 3 {
                return "Reminder will be sent on \(dayNames.joined(separator: ", "))"
            } else {
                return "Reminder will be sent on selected days"
            }
        }
    }
}

struct DayButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : ThemeColors.adaptivePrimary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? ThemeColors.adaptivePrimary : ThemeColors.adaptiveSecondaryBackground)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.clear : ThemeColors.adaptivePrimary.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Theme Colors
struct ThemeColors {
    // Legacy static colors (kept for reference but not recommended for direct use)
    static let primary = Color(hex: "555879")
    static let backgroundLight = Color(hex: "F4EFE8")
    static let backgroundCards = Color(hex: "F0EBE2")
    static let accent = Color(hex: "DED3C4")
    static let textPrimary = Color(hex: "333333")
    static let textSecondary = Color(hex: "6B6B6B")
    
    // Dark mode colors
    static let darkBackground = Color(hex: "2B3244")
    static let darkCards = Color(hex: "4A5068")
    static let darkBorders = Color(hex: "98A1BC")
    static let darkTextPrimary = Color(hex: "E8EBF0")
    static let darkTextSecondary = Color(hex: "B8C1D6")
    
    // MARK: - Dynamic Adaptive Colors
    
    /// Primary brand color that adapts to light/dark mode
    static var adaptivePrimary: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.75, green: 0.8, blue: 0.95, alpha: 1.0) // Much lighter purple for dark mode visibility
            } else {
                return UIColor(red: 0.33, green: 0.35, blue: 0.47, alpha: 1.0) // Original #555879
            }
        })
    }
    
    /// Primary background color (for buttons, highlights)
    static var adaptivePrimaryBackground: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.45, green: 0.5, blue: 0.7, alpha: 1.0) // Medium purple for dark mode buttons
            } else {
                return UIColor(red: 0.33, green: 0.35, blue: 0.47, alpha: 1.0) // Original #555879
            }
        })
    }
    
    /// Primary text color (white on primary background)
    static var adaptivePrimaryText: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.white // White text on dark purple buttons
            } else {
                return UIColor.white // White text on purple buttons
            }
        })
    }
    
    /// Card and surface background color
    static var adaptiveCardBackground: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1.0) // Darker cards for better contrast
            } else {
                return UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0) // Very light cards
            }
        })
    }
    
    /// Secondary surface background (slightly different from cards)
    static var adaptiveSecondaryBackground: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0) // Even darker secondary surface
            } else {
                return UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0) // Light secondary surface
            }
        })
    }
    
    /// Accent color for highlights and selections
    static var adaptiveAccent: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.7, green: 0.55, blue: 0.9, alpha: 1.0) // Bright purple accent for dark mode
            } else {
                return UIColor(red: 0.45, green: 0.35, blue: 0.6, alpha: 1.0) // Purple accent for light mode
            }
        })
    }
    
    /// Resource button background (purple with white iconography in light mode)
    static var adaptiveResourceButtonBackground: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.45, green: 0.5, blue: 0.7, alpha: 1.0) // Medium purple for dark mode
            } else {
                return UIColor(red: 0.33, green: 0.35, blue: 0.47, alpha: 1.0) // Purple background for white icons
            }
        })
    }
    
    /// Resource button icon color (always white for contrast)
    static var adaptiveResourceButtonIcon: Color {
        Color(UIColor { traitCollection in
            return UIColor.white // Always white for good contrast on purple
        })
    }
    
    /// Main system background (replaces UIColor.systemBackground)
    static var adaptiveSystemBackground: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 1.0) // Very dark gray for dark mode
            } else {
                return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // Pure white for light mode
            }
        })
    }
    
    /// Tertiary system background (for grouped content)
    static var adaptiveTertiaryBackground: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0) // Medium dark for dark mode
            } else {
                return UIColor(red: 0.92, green: 0.92, blue: 0.95, alpha: 1.0) // Light tertiary for light mode
            }
        })
    }
}


// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
