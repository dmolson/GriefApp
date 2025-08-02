# Light After Loss - Grief Support App

A compassionate iOS application designed to support individuals navigating their grief journey through practical tools, gentle reminders, and meaningful rituals.

## 🌟 Overview

Light After Loss provides a private, non-judgmental space for grief support based on three core principles:
- **Reaching out for help** - Making it easier to ask for support when needed
- **Getting in touch with feelings** - Providing tools and reminders for emotional processing  
- **Creating rituals** - Establishing meaningful ways to remember and honor loved ones

## 📱 Features

### Ask for Help
- Pre-written message templates for requesting support
- Practical and emotional support suggestions
- Easy sharing options to reach out to your support network

### Daily Reminders
- Customizable notification times
- Rotating supportive quotes and messages
- Gentle touchpoints throughout your day

### Rituals
- Create personal rituals for connection, reflection, birthdays, and anniversaries
- Photo integration and symbolic imagery
- Step-by-step ritual creation guide

### Resources
- Crisis support information (988 Suicide & Crisis Lifeline)
- Grief support groups and helplines
- Addiction resources for families
- Important awareness dates

## 🛠 Technical Details

### Requirements
- iOS 18.5+
- Xcode 16.4+
- Swift 5.0

### Architecture
- SwiftUI-based interface
- MVVM architecture pattern
- Local data storage for privacy
- Dark mode support

### Project Structure
```
Grief Support/
├── Grief Support/
│   ├── Grief_SupportApp.swift    # App entry point
│   ├── ContentView.swift         # Main tab navigation
│   ├── Views/                    # Feature views
│   │   ├── AskForHelpView.swift
│   │   ├── RemindersView.swift
│   │   ├── RitualsView.swift
│   │   ├── ResourcesView.swift
│   │   ├── SettingsView.swift
│   │   └── CommonComponents.swift
│   ├── Design-Docs/              # Design documentation
│   │   ├── context.md           # Core experience design
│   │   ├── development-log.md   # Development history
│   │   └── readme.md
│   └── Prototypes/              # HTML wireframes
│       └── grief_support_wireframe.html
```

## 🚀 Getting Started

1. Clone the repository
2. Open `Grief Support.xcodeproj` in Xcode
3. Select your target device/simulator
4. Build and run (⌘+R)

## 📖 Documentation

For detailed information about the app's design philosophy, user experience principles, and feature specifications, please refer to:

- **[Core Experience Design](Grief%20Support/Design-Docs/context.md)** - Comprehensive design documentation including color palettes, typography, and UX principles
- **[Development Log](Grief%20Support/Design-Docs/development-log.md)** - Implementation history and technical decisions
- **[Interactive Prototype](Grief%20Support/Prototypes/grief_support_wireframe.html)** - HTML wireframe demonstrating the app flow

## 🎨 Design System

### Color Palette
- **Primary**: #555879 (Muted purple-gray)
- **Background**: #F4EFE8 (Warm cream)
- **Cards**: #F0EBE2 (Light beige)
- **Accent**: #DED3C4 (Warm gray-beige)

### Typography
- **Primary**: Inter (clean sans-serif)
- **Secondary**: Cormorant Garamond (elegant serif for quotes)

## 🤝 Contributing

This app was created with care to support those experiencing grief. If you'd like to contribute:

1. Read the design documentation to understand the app's philosophy
2. Ensure any changes maintain the gentle, non-judgmental tone
3. Test thoroughly with accessibility in mind
4. Submit pull requests with clear descriptions

## 📄 License

[License information to be added]

## 💙 Acknowledgments

This app is dedicated to all those navigating the difficult journey of grief. May it provide some light in dark moments.

---

*"Grief is love with nowhere to go" — Jamie Anderson*