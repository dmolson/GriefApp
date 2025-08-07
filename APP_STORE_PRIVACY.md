# App Store Privacy Details for Light After Loss

## App Store Connect Privacy Nutrition Label

This document provides the complete privacy information needed for App Store submission. Use this information when filling out the privacy section in App Store Connect.

---

## Data Collection Summary

### Does your app collect data from this app?
**Answer: NO**

Light After Loss does not collect any data from users. All information is stored locally on the user's device and is never transmitted to our servers or third parties.

---

## Data Types and Usage

### 1. Contact Info
- **Email Address**: NOT collected (only optionally provided for bug reports via device email client)
- **Name**: NOT collected (loved ones' names are stored locally only)
- **Phone Number**: NOT collected
- **Physical Address**: NOT collected
- **Other Contact Info**: NOT collected

### 2. Health & Fitness  
- **Health Data**: NOT collected
- **Fitness Data**: NOT collected

### 3. Financial Info
- **Payment Info**: NOT collected
- **Credit Info**: NOT collected
- **Other Financial Info**: NOT collected

### 4. Location
- **Precise Location**: NOT collected
- **Coarse Location**: NOT collected

### 5. Sensitive Info
- **Sensitive Info**: NOT collected

### 6. Contacts
- **Contacts**: NOT accessed (app only uses share sheet when user initiates)

### 7. User Content
- **Photos or Videos**: Stored locally only (when user adds to rituals)
- **Audio Data**: NOT collected
- **Gameplay Content**: NOT applicable
- **Customer Support**: Email only when user initiates support
- **Other User Content**: Stored locally only (rituals, reminders)

### 8. Browsing History
- **Browsing History**: NOT collected

### 9. Search History
- **Search History**: NOT collected (music searches handled by Apple Music/Spotify)

### 10. Identifiers
- **User ID**: NOT collected
- **Device ID**: NOT collected
- **Purchase History**: NOT collected

### 11. Usage Data
- **Product Interaction**: NOT collected
- **Advertising Data**: NOT collected
- **Other Usage Data**: NOT collected

### 12. Diagnostics
- **Crash Data**: NOT collected
- **Performance Data**: NOT collected
- **Other Diagnostic Data**: NOT collected

### 13. Other Data
- **Other Data Types**: NOT collected

---

## Third-Party Data Sharing

### Does your app share data with third parties?
**Answer: NO**

The app does not share any user data with third parties. Music service integrations (Apple Music, Spotify) are handled through their official SDKs with user permission, but no personal data is shared.

---

## Data Linked to User

### Is any collected data linked to the user's identity?
**Answer: NO**

Since we don't collect any data, nothing is linked to user identity.

---

## Tracking

### Does your app track users?
**Answer: NO**

Light After Loss does not track users. We do not use any analytics, advertising identifiers, or tracking technologies.

---

## Privacy Policy

### Privacy Policy URL
Please host the PRIVACY_POLICY.md file on your website and provide the URL in App Store Connect.

**Suggested URL**: https://yourwebsite.com/privacy

---

## Required Privacy Information Keys

The following keys are configured in your project:

### ✅ Configured Permissions:
1. **NSCalendarsUsageDescription** - Calendar access for memorial reminders
2. **NSContactsUsageDescription** - Contact access for message sharing
3. **NSFaceIDUsageDescription** - Biometric security for private data
4. **NSPhotoLibraryUsageDescription** - Photo access for rituals
5. **NSUserNotificationsUsageDescription** - Notifications for grief support

### ⚠️ Needs Addition:
1. **NSAppleMusicUsageDescription** - Apple Music access for memorial songs

---

## App Store Review Notes

### Suggested Review Notes:
```
Light After Loss is a privacy-focused grief support app that stores all user data locally on their device. 

Key Privacy Features:
- NO data collection or transmission to servers
- NO user tracking or analytics
- NO third-party data sharing
- All personal information stays on device
- Optional permissions only requested when features are used
- Complete user control with data reset options

The app requests permissions only when users choose to use specific features:
- Photos: Only when adding images to memorial rituals
- Music: Only when adding songs to rituals
- Notifications: Only when setting up reminders
- Calendar: Only when adding memorial dates
- Contacts: Only when sharing support messages

All features work offline and data never leaves the user's device.
```

---

## Encryption Declaration

### Does your app use encryption?
**Answer: NO** (ITSAppUsesNonExemptEncryption = NO)

The app uses only standard iOS encryption for local data storage (iOS Keychain for tokens) which is exempt from export compliance.

---

## Age Rating

### Suggested Age Rating: 12+
**Reasons:**
- Infrequent/Mild Mature/Suggestive Themes (grief and loss content)
- No violence, profanity, or adult content
- Appropriate for teens and adults dealing with grief

---

## Categories

### Primary Category
**Health & Fitness**

### Secondary Category (Optional)
**Lifestyle**

---

## Data Retention

### How long do you retain user data?
**Not Applicable** - All data is stored locally on device and controlled by the user. Users can delete all data at any time through the app's Settings.

---

## Children's Privacy

### Is your app directed to children under 13?
**Answer: NO**

Light After Loss is designed for teens and adults dealing with grief and loss.

---

## Location Services

### Does your app use location services?
**Answer: NO**

---

## Account Creation

### Does your app require account creation?
**Answer: NO**

The app works completely offline without any user accounts.

---

## Sign-In Methods

### What sign-in methods does your app support?
**None** - No sign-in required

### Third-party sign-in:
- Apple Music: Optional OAuth for music integration only
- Spotify: Optional OAuth for music integration only  

Note: These are feature integrations, not sign-in methods for the app itself.

---

## Data Deletion

### Can users delete their data?
**Answer: YES**

Users can delete all data through Settings > Reset Everything, or selectively delete:
- Individual loved ones
- Individual reminders  
- Individual rituals
- Music preferences
- All settings

---

## GDPR Compliance

### For European Users:
- **Data Controller**: Not applicable (no data collection)
- **Data Processor**: Not applicable (no data processing)
- **Legal Basis**: Not applicable (no data collection)
- **Data Protection Officer**: Not required (no data collection)
- **EU Representative**: Not required (no data collection)

---

## CCPA Compliance

### For California Users:
- **Personal Information Collected**: None
- **Sale of Personal Information**: No
- **Right to Delete**: Yes (local data control)
- **Right to Know**: Not applicable (no collection)
- **Right to Opt-Out**: Not applicable (no sale of data)

---

## Contact Information

### Privacy Contact
**Email**: wearesoulfulai@gmail.com

Please ensure this email is monitored for privacy-related inquiries from users and Apple.

---

## Checklist for App Store Submission

Before submitting to App Store:

- [ ] Host PRIVACY_POLICY.md on your website
- [ ] Add privacy policy URL to App Store Connect
- [ ] Add NSAppleMusicUsageDescription to Info.plist
- [ ] Verify all permission descriptions are present
- [ ] Test all permission requests in the app
- [ ] Ensure "Reset Everything" feature works properly
- [ ] Verify no analytics or tracking code is present
- [ ] Review all third-party SDKs for privacy compliance
- [ ] Add privacy contact email to App Store Connect
- [ ] Select "No" for data collection in privacy section
- [ ] Set ITSAppUsesNonExemptEncryption to NO

---

*Last Updated: January 2025*
*Document Version: 1.0*