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
5. **Settings** - Loved ones management, appearance, data controls, and music integrations
6. **Theme System** - Responsive dark/light mode with adaptive colors
7. **Font System** - Custom fonts (Melodrama-Medium for headers) with easy revert capability
8. **Bug Reporting** - In-app feedback system for user issues

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
- ✅ All build errors resolved and app compiling successfully

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