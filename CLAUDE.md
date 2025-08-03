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

## Key Features Implemented
1. **Ask for Help** - Message templates and support suggestions
2. **Daily Reminders** - Customizable notifications with supportive quotes
3. **Rituals** - Create meaningful remembrance activities
4. **Resources** - Crisis support, grief groups, and awareness information
5. **Settings** - Loved ones management, appearance, and data controls

## File Structure
```
Grief Support/
├── Grief_SupportApp.swift     # App entry point
├── ContentView.swift          # Main tab controller
├── Views/                     # Feature views
│   ├── AskForHelpView.swift
│   ├── RemindersView.swift
│   ├── RitualsView.swift
│   ├── ResourcesView.swift
│   ├── SettingsView.swift
│   └── CommonComponents.swift
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
- Fixed build warnings by excluding Design-Docs and Prototypes folders from compilation
- Created comprehensive README for public repository
- Set up demo recording infrastructure using iOS Simulator's built-in video capture
- All documentation files properly linked and accessible

## Next Steps Considerations
- Implement data persistence (Core Data or SwiftData)
- Add notification scheduling functionality
- Integrate photo picker for ritual creation
- Implement music integration for rituals
- Add accessibility improvements
- Consider watchOS companion app

## Important Files for Context
- `Design-Docs/context.md` - Complete design specification
- `README.md` - Public-facing project documentation
- `DEMO_GUIDE.md` - App demonstration walkthrough

---
*Last updated: August 2, 2025*