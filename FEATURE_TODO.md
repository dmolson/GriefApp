# Feature To-Do List - Light After Loss

## High Priority Features

### 🤖 AI-Powered Ritual Template Generation
**Status:** Not Started  
**Priority:** High  
**Estimated Effort:** Large  

**Description:**
Implement an AI-powered feature that helps users generate personalized ritual templates using Apple's Foundation Model framework. This would replace the current "Browse Templates" functionality with a more intelligent, personalized approach.

**Technical Implementation:**
- Integrate Apple's Foundation Model framework (iOS 18.5+)
- Create guided prompting system for user input
- Generate contextually appropriate ritual suggestions
- Allow users to customize and save generated templates

**User Experience Flow:**
1. User selects ritual type (Connection, Reflection, Birthday, Anniversary)
2. AI presents guided questions to understand user's needs:
   - Relationship to loved one
   - Preferred activities/settings
   - Emotional state/goals for the ritual
   - Time constraints
   - Personal preferences
3. AI generates 2-3 personalized ritual templates
4. User can customize, save, or regenerate options

**Benefits:**
- Personalized content based on individual grief journey
- Reduces decision fatigue during difficult times
- Provides inspiration when users feel stuck
- Learns from user preferences over time

**Requirements:**
- iOS 18.5+ for Foundation Model access
- Privacy-focused implementation (on-device processing)
- Fallback templates for users who prefer not to use AI
- Clear consent and explanation of AI usage

---

## Medium Priority Features

### 📧 Bug Report Email Integration
**Status:** UI Complete, Backend Needed  
**Priority:** Medium  

- Implement actual email sending to wearesoulfulai@gmail.com
- Add device info and app version to bug reports
- Handle email client availability gracefully

### 🔄 Resources Content Updates
**Status:** Pending Updates  
**Priority:** Medium  

- Update "Addiction Resources" to "Family Addiction Resources"
- Expand Families Anonymous description to include mental health support
- Verify and update all resource links and contact information

### 📱 Enhanced Reminder Notifications
**Status:** Not Started  
**Priority:** Medium  

- Integrate with iOS notification system
- Add location-based reminders
- Smart scheduling based on user patterns

### 💾 Data Persistence
**Status:** Not Started  
**Priority:** Medium  

- Implement Core Data or SwiftData
- Save user rituals, reminders, and preferences
- iCloud sync for cross-device access

### ♿ Accessibility Improvements
**Status:** Not Started  
**Priority:** Medium  

- VoiceOver optimization
- Dynamic Type support
- High contrast mode support
- Voice input for ritual creation

---

## Low Priority Features

### 🎵 Music Integration Enhancement
**Status:** Framework Complete  
**Priority:** Medium  

- Complete actual Spotify/Apple Music API integration (currently simulated)
- Add playlist creation for rituals
- Implement ritual playback full-screen view
- Add mood-based music suggestions

### ⌚ watchOS Companion App
**Status:** Not Started  
**Priority:** Low  

- Quick reminder access
- Gentle vibration notifications
- Simple ritual logging

### 📊 Progress Tracking
**Status:** Not Started  
**Priority:** Low  

- Grief journey insights
- Ritual completion tracking
- Mood journaling integration

---

## Research & Planning

### AI Template Generation Deep Dive

**Technical Research Needed:**
- Foundation Model API capabilities and limitations
- On-device vs cloud processing options
- Privacy implications and user consent flows
- Performance impact on older devices
- Backup content generation strategies

**Content Research:**
- Grief counseling best practices
- Cultural sensitivity considerations
- Age-appropriate content guidelines
- Crisis intervention protocols

**UX Research:**
- User testing of AI interaction patterns
- Preference for AI vs human-curated content
- Trust and transparency requirements
- Customization vs automation balance

---

## Notes

- All AI features should be optional with clear user consent
- Maintain privacy-first approach with on-device processing when possible
- Ensure graceful degradation for users who opt out of AI features
- Consider offline functionality for core app features

## Completed Features (Recent)

### ✅ Settings Dark Mode Fix
**Status:** Complete  
**Date:** August 2025  
- Fixed header visibility in dark mode
- Implemented adaptive colors for navigation elements
- Added responsive theme switching

### ✅ Photo Management System
**Status:** Complete  
**Date:** August 2025  
- Added photo upload with 5-photo limit
- Implemented photo grid display
- Added photo deletion functionality
- Included "none" option for preset images

### ✅ Custom Font System
**Status:** Complete  
**Date:** August 2025  
- Implemented Melodrama-Medium for headers
- Added Satoshi font support with toggle system
- Created easy revert capability via FontConfig

### ✅ Bug Reporting System
**Status:** UI Complete  
**Date:** August 2025  
- Added in-app bug report dialog
- Implemented issue type classification
- Added 300-character description limit
- Created submission confirmation flow

### ✅ Reset Functionality
**Status:** Complete  
**Date:** August 2025  
- Implemented reset for reminders, rituals, loved ones
- Added music integrations reset
- Created confirmation dialogs with safety measures

### ✅ Custom Reminder Times
**Status:** Complete  
**Date:** August 2025  
- Added time customization interface
- Preserved existing reminder messages
- Implemented save/cancel functionality

**Last Updated:** August 3, 2025