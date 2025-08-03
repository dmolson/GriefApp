# Light After Loss - Grief Support App

## Project Overview
This is a compassionate iOS application designed to support individuals navigating their grief journey. Built with SwiftUI, the app provides practical tools, gentle reminders, and meaningful rituals to help users process their emotions and connect with support networks.

## Current Status
- ✅ Core SwiftUI architecture implemented
- ✅ Main tab navigation with 4 primary sections
- ✅ Basic UI for Ask for Help, Reminders, Rituals, and Resources
- ✅ Settings menu with personalization options
- ✅ Build warnings resolved (markdown files excluded from compilation)
- ✅ Comprehensive README and documentation added
- ✅ Demo recording tools and guide created
- ✅ Project committed to GitHub repository

## Technical Stack
- **Platform**: iOS 18.5+
- **Framework**: SwiftUI
- **Architecture**: MVVM pattern
- **Deployment**: Xcode 16.4+
- **Dependencies**: Swift Algorithms package
- **Fonts**: Melodrama-Medium (headers), Satoshi (body text with easy toggle)

## Key Features Implemented
1. **Ask for Help** - Message templates and support suggestions with share sheet
2. **Daily Reminders** - Customizable notifications with supportive quotes and custom times
3. **Rituals** - Create meaningful remembrance activities with photo management and music integration
4. **Resources** - Crisis support, grief groups, and awareness information
5. **Settings** - Complete loved ones management with edit/delete/add functionality, appearance controls, data management, and music integrations
6. **Theme System** - Responsive dark/light mode with adaptive colors
7. **Font System** - Custom fonts (Melodrama-Medium for headers) with easy revert capability
8. **Bug Reporting** - In-app feedback system for user issues
9. **Loved Ones Management** - Full CRUD operations with elegant UX, confirmation dialogs, and real-time updates

## File Structure
```
Grief Support/
├── Grief_SupportApp.swift     # App entry point
├── ContentView.swift          # Main tab controller
├── Views/                     # Feature views
│   ├── AskForHelpView.swift   # Help templates with ShareSheet
│   ├── RemindersView.swift    # Custom times and notifications
│   ├── RitualsView.swift      # Photo management and music integration
│   ├── ResourcesView.swift    # Support resources
│   ├── SettingsView.swift     # Complete settings with bug reporting
│   └── CommonComponents.swift # Adaptive theme colors
├── Fonts/                     # Font system
│   ├── FontExtensions.swift   # Custom font management
│   └── Melodrama-Medium.otf   # Header font
├── Design-Docs/               # Design documentation
│   ├── context.md            # Core design principles
│   ├── development-log.md    # Implementation history
│   └── readme.md
└── Prototypes/               # HTML wireframes
```

## Design Philosophy
- **Non-judgmental**: Inclusive language for all types of loss
- **Gentle**: Soft color palette (#555879 primary, warm cream backgrounds)
- **Private**: No social features, focus on personal journey
- **Empowering**: User-controlled experience through customization
- **Adaptive**: Responsive dark/light mode with immediate visual feedback
- **Accessible**: Easy-to-use font system with toggle capabilities

## Build Commands
```bash
# Build for simulator
xcodebuild -project "Grief Support.xcodeproj" -scheme "Grief Support" -destination "platform=iOS Simulator,name=iPhone 16" build

# Install on simulator
xcrun simctl install booted "path/to/Grief Support.app"

# Launch app
xcrun simctl launch booted dmolson.Grief-Support
```

## Demo Recording
- Recording script: `demo_recording.sh`
- Demo guide: `DEMO_GUIDE.md`
- Output: Creates QuickTime-compatible video files

## GitHub Repository
https://github.com/dmolson/GriefApp

## Recent Development Notes
- ✅ Fixed Settings dark mode visibility issues with adaptive colors
- ✅ Implemented responsive theme switching with immediate visual feedback
- ✅ Added comprehensive photo management for rituals (5-photo limit)
- ✅ Implemented custom times functionality for reminders
- ✅ Added bug reporting system with in-app dialog
- ✅ Created music integration framework for Spotify/Apple Music
- ✅ Added reset functionality for all saved data types
- ✅ Updated font system to Melodrama-Medium for headers with easy revert
- ✅ Fixed ShareSheet for message functionality with iPad compatibility
- ✅ **Fixed disappearing rituals page issue** - Removed duplicate/conflicting files and stabilized implementation
- ✅ **Implemented complete "Your Loved Ones" management system** - Edit, delete, and add functionality with elegant UX
- ✅ All build errors resolved and app compiling successfully

## Critical Issue Resolved: Disappearing Rituals Page
**Problem**: The rituals page functionality was disappearing during development due to multiple conflicting file versions.

**Root Cause**: 
- Multiple versions of RitualsView files existed (RitualsView.swift, RitualsViewNew.swift, RitualsViewSimple.swift)
- During development, the main implementation was being overwritten by stub versions
- Build system confusion between multiple files with similar names

**Solution Implemented**:
1. Restored stable RitualsView.swift implementation from backup
2. Removed duplicate/conflicting files (RitualsViewNew.swift, RitualsViewSimple.swift) 
3. Added proper .gitignore to prevent build artifacts from being committed
4. Cleaned build artifacts to ensure fresh compilation
5. Committed stable version to prevent future loss

**Prevention Measures**:
- ✅ Added comprehensive .gitignore file
- ✅ Removed all duplicate ritual view files
- ✅ Committed stable implementation to version control
- ✅ Documented issue and solution for future reference

**Development Best Practices**:
- Always use proper branching for experimental features
- Never create multiple files with similar names in the same scope
- Regularly commit working implementations
- Clean build artifacts when encountering persistent build issues

## New Feature Implemented: Complete "Your Loved Ones" Management System
**Problem**: The three dot button (ellipsis) in "Your Loved Ones" cards had no functionality, and the "Add Someone Special" button was non-functional.

**Solution Implemented**:

### **🎯 Three Dot Button Features**
- **Action Sheet** - Tap the enhanced three dot button to see "Edit Details" and "Delete" options
- **Improved Design** - The button now has a subtle background circle and better visual feedback
- **Confirmation Dialogs** - Safe deletion with clear warning messages

### **✏️ Edit Functionality** 
- **Full Edit Sheet** - Modal interface to modify name, birth date, date of passing, and reminder settings
- **Smart Date Parsing** - Automatically converts existing date strings to editable date pickers
- **Form Validation** - Cannot save with empty names, disabled state for save button
- **Cancel/Save Actions** - Proper navigation with cancel and save options in toolbar

### **🗑️ Delete Functionality**
- **Confirmation Dialog** - Two-step deletion process with confirmation alert
- **Clear Messaging** - Explains the action is permanent and cannot be undone
- **Graceful Removal** - Smoothly removes the person from the list with proper state management

### **➕ Enhanced "Add Someone Special"**
- **Fully Functional** - The button was previously non-functional, now properly adds loved ones to the list
- **Better UX** - Clearer date field labels ("Birth date", "Date of passing") with proper spacing
- **Form Validation** - Button is disabled when name field is empty, prevents invalid submissions
- **Auto-Reset** - Form automatically clears after successfully adding someone
- **Date Formatting** - Uses proper date formatter for consistent display

### **🔄 Live Updates & State Management**
- **Toggle Sync** - Birthday and memorial reminder toggles update immediately in both card and edit views
- **Real-time Changes** - All edits are reflected instantly in the UI without page refresh
- **Proper Data Flow** - Callback-based architecture ensures state consistency across components
- **Mutable Data Model** - Updated LovedOne struct to support editing while maintaining data integrity

### **🎨 Elegant Design & UX**
- **Consistent UI** - Matches app's design language with CardView components and ThemeColors
- **User-Friendly Interactions** - Intuitive confirmation dialogs and clear action sheets
- **Responsive Design** - Works seamlessly across different device sizes and orientations
- **Accessibility** - Proper button roles (destructive for delete, cancel for cancel actions)

**Files Modified**:
- `SettingsView.swift:187-540` - Added complete loved ones management system with edit sheet, action dialogs, and functional add button

## Next Steps Considerations
- Complete music integration with actual Spotify/Apple Music APIs
- Implement data persistence (Core Data or SwiftData)
- Add notification scheduling functionality
- Complete ritual playback full-screen view
- Implement email integration for bug reports to wearesoulfulai@gmail.com
- Add AI-powered template generation feature (using Apple's Foundation Model)
- Add accessibility improvements
- Consider watchOS companion app

## Important Files for Context
- `Design-Docs/context.md` - Complete design specification
- `README.md` - Public-facing project documentation
- `DEMO_GUIDE.md` - App demonstration walkthrough

---
*Last updated: August 2, 2025*