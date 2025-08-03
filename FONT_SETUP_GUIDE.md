# Font Setup Guide for Light After Loss

## Step 1: Download Fonts

### Chubbo Font (Main Header)
1. Visit: https://www.fontshare.com/fonts/chubbo
2. Click "Download Family"
3. Download all weights (Regular, Medium, SemiBold, Bold, etc.)
4. Extract the ZIP file

### Excon Font (Headers)
1. Visit: https://www.fontshare.com/fonts/excon
2. Click "Download Family" 
3. Download all weights (Regular, Medium, SemiBold, Bold, etc.)
4. Extract the ZIP file

### Satoshi Font (Body Text)
1. Visit: https://www.fontshare.com/fonts/satoshi
2. Click "Download Family"
3. Download all weights (Regular, Medium, SemiBold, Bold, etc.)
4. Extract the ZIP file

## Step 2: Add Fonts to Xcode Project

1. In Xcode, right-click on the "Grief Support" folder
2. Select "Add Files to 'Grief Support'"
3. Navigate to the downloaded font files
4. Select all `.ttf` or `.otf` files for Melodrama-Medium and Satoshi fonts
5. Make sure "Add to target" has "Grief Support" checked
6. Click "Add"

## Step 3: Update Info.plist

Add the following to your `Info.plist` file:

```xml
<key>UIAppFonts</key>
<array>
    <!-- Melodrama Font File -->
    <string>Melodrama-Medium.otf</string>
    
    <!-- Satoshi Font Files (Optional) -->
    <string>Satoshi-Regular.ttf</string>
    <string>Satoshi-Medium.ttf</string>
    <string>Satoshi-SemiBold.ttf</string>
    <string>Satoshi-Bold.ttf</string>
    <string>Satoshi-Light.ttf</string>
    <string>Satoshi-Black.ttf</string>
</array>
```

## Step 4: Verify Font Names

After adding the fonts, you might need to adjust the font names in `FontExtensions.swift`. The actual PostScript names might be different. To check:

1. Build and run the app
2. Add this code to your app's initialization to print available fonts:

```swift
FontLoader.loadFonts()
```

3. Check the console output for the exact font names
4. Update the `satoshiFontName` function if needed (Melodrama-Medium is already configured)

## Step 5: Test the Fonts

After completing the setup:

1. Build and run the app
2. Verify that the main "Light After Loss" header uses Melodrama-Medium font
3. Verify that body text uses Satoshi font (if enabled via FontConfig.USE_SATOSHI)
4. Check that the font toggle system works correctly
5. Test fallback to system fonts when custom fonts are disabled

## Font Usage in Code

The app now uses these semantic font styles:

### Main Header (Melodrama-Medium)
- `.appHeaderTitle` - 35pt Medium (for "Light After Loss")

### Body Text (Satoshi - toggleable)
- `.appBody` - 16pt Regular
- `.appBodySmall` - 14pt Regular
- `.appBodyLarge` - 18pt Regular
- `.appCaption` - 12pt Regular
- `.appHeadline` - 18pt Medium
- `.appLargeTitle` - 24pt Bold
- `.appSubheadline` - 15pt Medium
- `.buttonText` - 16pt Medium
- `.supportiveText` - 15pt Medium
- `.quoteText` - 15pt Medium

### Font Toggle System
- Set `FontConfig.USE_SATOSHI = true` to enable Satoshi fonts
- Set `FontConfig.USE_SATOSHI = false` to use system fonts
- Easy revert capability for testing purposes

## Notes

- All fonts will fallback to system fonts if custom fonts fail to load
- The FontExtensions.swift file provides easy access to both fonts
- Font weights are automatically mapped to available font files
- The app maintains the existing color scheme and spacing
- FontConfig.USE_SATOSHI toggle provides easy switching between custom and system fonts
- Melodrama-Medium is always used for the main header regardless of toggle setting

## Troubleshooting

If fonts don't appear:

1. Check that font files are added to the app bundle
2. Verify Info.plist entries match actual font file names
3. Use FontLoader.loadFonts() to see what fonts are available
4. Check that font family names match what you're using in code