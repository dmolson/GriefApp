# App Store Connect Privacy Responses Guide

## Quick Reference for App Store Connect Privacy Section

This document provides copy-paste ready responses for each privacy question in App Store Connect.

---

## Section 1: Data Collection

### Question: "Does your app collect data from this app?"
**Select:** ❌ **No, we do not collect data from this app**

---

## Section 2: Data Types (If Apple asks for clarification)

If Apple requires you to specify data handling despite selecting "No collection":

### Contact Info
- **Collected:** No
- **Used for Tracking:** No
- **Linked to User:** No

### Health & Fitness
- **Collected:** No
- **Used for Tracking:** No
- **Linked to User:** No

### Financial Info
- **Collected:** No
- **Used for Tracking:** No
- **Linked to User:** No

### Location
- **Collected:** No
- **Used for Tracking:** No
- **Linked to User:** No

### Sensitive Info
- **Collected:** No
- **Used for Tracking:** No
- **Linked to User:** No

### Contacts
- **Collected:** No
- **Used for Tracking:** No
- **Linked to User:** No

### User Content
- **Photos/Videos:** Stored locally only, not collected
- **Audio:** Not collected
- **Other Content:** Stored locally only, not collected

### Browsing History
- **Collected:** No

### Search History  
- **Collected:** No

### Identifiers
- **Collected:** No

### Purchases
- **Collected:** No

### Usage Data
- **Collected:** No

### Diagnostics
- **Collected:** No

### Other Data
- **Collected:** No

---

## Section 3: Review Notes

### App Review Information

**Demo Account Required:** No (app works without accounts)

**Special Instructions:**
```
Light After Loss is a privacy-focused grief support app. Key points for review:

1. NO data collection - all data stored locally on device
2. NO user accounts required - app works completely offline  
3. NO tracking or analytics
4. NO third-party data sharing

Permission requests are optional and only triggered when users access specific features:
- Photos: When adding images to rituals
- Apple Music: When adding songs to rituals
- Notifications: When setting reminders
- Calendar: When adding memorial dates
- Contacts: When sharing messages

All features respect user privacy and work entirely on-device.
```

---

## Section 4: Privacy Policy

### Privacy Policy URL
**Enter your hosted privacy policy URL**

Example: `https://[yourdomain]/privacy-policy`

*Note: You must host the PRIVACY_POLICY.md content on a publicly accessible webpage*

### Privacy Policy Contact
**Email:** wearesoulfulai@gmail.com

---

## Section 5: Encryption

### Export Compliance

**Uses Encryption:** No
**Exempt:** Yes (only uses standard iOS encryption)
**ITSAppUsesNonExemptEncryption:** NO

---

## Section 6: Third-Party Content

### Question: "Does your app display third-party content?"
**Answer:** No

### Question: "Does your app contain third-party analytics?"
**Answer:** No

### Question: "Does your app contain third-party advertising?"
**Answer:** No

---

## Section 7: Permissions

### Available Permissions Used:

✅ **Apple Music**
- Purpose: Add meaningful songs to memorial rituals
- Required: No (optional feature)

✅ **Calendar**
- Purpose: Add memorial date reminders
- Required: No (optional feature)

✅ **Contacts**  
- Purpose: Share support messages
- Required: No (optional feature)

✅ **Face ID/Touch ID**
- Purpose: Secure private grief data
- Required: No (optional feature)

✅ **Photo Library**
- Purpose: Add photos to rituals
- Required: No (optional feature)

✅ **Notifications**
- Purpose: Grief support reminders
- Required: No (optional feature)

---

## Section 8: IDFA (Identifier for Advertisers)

### Question: "Does this app use the Advertising Identifier (IDFA)?"
**Answer:** No

---

## Section 9: Additional Information

### Kids Category
**Is your app made for kids?** No

### Age Rating
**Suggested Rating:** 12+
- Infrequent/Mild Mature/Suggestive Themes

### Content Rights
**Does your app contain, display, or access third-party content?** No

### Contests
**Does your app conduct contests?** No

### Login
**Does your app require login?** No

### Personal Information
**Does your app access personal information?** Yes, but only locally stored
- Photos (optional, user-initiated)
- Calendar (optional, user-initiated)
- Contacts (optional, for sharing only)

---

## Common Rejection Reasons & Responses

### If Rejected for Privacy Policy:

**Response Template:**
```
Thank you for your review. Light After Loss includes a comprehensive privacy policy that explains:

1. We collect NO data from users
2. All information stays on the user's device
3. No tracking, analytics, or third-party sharing
4. Complete user control over their data

Privacy Policy URL: [Your URL]

The privacy policy is also included in the app bundle as PRIVACY_POLICY.md and linked from our Settings screen.
```

### If Rejected for Permissions:

**Response Template:**
```
All permission requests in Light After Loss are:

1. Optional - core app functions without any permissions
2. Contextual - only requested when user initiates the feature
3. Clearly explained - each permission has detailed usage descriptions
4. Privacy-focused - data never leaves the device

We've added detailed descriptions for all permissions:
- NSAppleMusicUsageDescription
- NSCalendarsUsageDescription  
- NSContactsUsageDescription
- NSFaceIDUsageDescription
- NSPhotoLibraryUsageDescription
- NSUserNotificationsUsageDescription
```

### If Asked About Data Storage:

**Response Template:**
```
Light After Loss uses only local storage:

1. UserDefaults for preferences and simple data
2. Local file system for photos (in app sandbox)
3. iOS Keychain for music service tokens
4. No remote servers or cloud storage
5. No CoreData or external databases

Users can delete all data via Settings > Reset Everything.
```

---

## Pre-Submission Checklist

Before submitting to App Store Connect:

- [ ] Privacy Policy hosted on public website
- [ ] Privacy Policy URL added to App Store Connect
- [ ] All permission descriptions in Info.plist
- [ ] PrivacyInfo.xcprivacy included in bundle
- [ ] Selected "No" for data collection
- [ ] Added review notes explaining privacy approach
- [ ] Tested all permission requests
- [ ] Verified Reset Everything works
- [ ] Set encryption exemption (ITSAppUsesNonExemptEncryption = NO)
- [ ] Privacy contact email configured

---

## Support Contact

For privacy questions from Apple Review Team:
**Email:** wearesoulfulai@gmail.com

---

## Quick Copy Section

### One-Line Privacy Statement
```
Light After Loss stores all data locally on device with no collection, tracking, or sharing.
```

### Review Notes (Short Version)
```
Privacy-first grief support app. No data collection, no accounts, no tracking. All data stored locally.
```

### Review Notes (Detailed Version)
```
Light After Loss is designed with privacy at its core:
- Zero data collection or transmission
- No user accounts or authentication required
- All personal information stored locally on device
- No analytics, tracking, or third-party sharing
- Optional permissions only when features are used
- Complete user control with data reset options
- Works entirely offline

The app helps users through grief with complete privacy and dignity.
```

---

*Document Version: 1.0*
*Last Updated: January 2025*
*For: Light After Loss iOS App Submission*