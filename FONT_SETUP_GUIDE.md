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

### Ranade Font (Body Text)
1. Visit: https://www.fontshare.com/fonts/ranade
2. Click "Download Family"
3. Download all weights (Regular, Medium, SemiBold, Bold, etc.)
4. Extract the ZIP file

## Step 2: Add Fonts to Xcode Project

1. In Xcode, right-click on the "Grief Support" folder
2. Select "Add Files to 'Grief Support'"
3. Navigate to the downloaded font files
4. Select all `.ttf` or `.otf` files for Chubbo, Excon, and Ranade
5. Make sure "Add to target" has "Grief Support" checked
6. Click "Add"

## Step 3: Update Info.plist

Add the following to your `Info.plist` file:

```xml
<key>UIAppFonts</key>
<array>
    <!-- Chubbo Font Files -->
    <string>Chubbo-Regular.ttf</string>
    <string>Chubbo-Medium.ttf</string>
    <string>Chubbo-SemiBold.ttf</string>
    <string>Chubbo-Bold.ttf</string>
    <string>Chubbo-Light.ttf</string>
    <string>Chubbo-Thin.ttf</string>
    <string>Chubbo-ExtraBold.ttf</string>
    <string>Chubbo-Black.ttf</string>
    
    <!-- Excon Font Files -->
    <string>Excon-Regular.ttf</string>
    <string>Excon-Medium.ttf</string>
    <string>Excon-SemiBold.ttf</string>
    <string>Excon-Bold.ttf</string>
    <string>Excon-Light.ttf</string>
    <string>Excon-Thin.ttf</string>
    <string>Excon-ExtraBold.ttf</string>
    <string>Excon-Black.ttf</string>
    
    <!-- Ranade Font Files -->
    <string>Ranade-Regular.ttf</string>
    <string>Ranade-Medium.ttf</string>
    <string>Ranade-SemiBold.ttf</string>
    <string>Ranade-Bold.ttf</string>
    <string>Ranade-Light.ttf</string>
    <string>Ranade-Thin.ttf</string>
    <string>Ranade-ExtraBold.ttf</string>
    <string>Ranade-Black.ttf</string>
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
4. Update the `chubboFontName`, `exconFontName` and `ranadeFontName` functions if needed

## Step 5: Test the Fonts

After completing the setup:

1. Build and run the app
2. Verify that the main "Light After Loss" header uses Chubbo font
3. Verify that other headers use Excon font
4. Verify that body text uses Ranade font
5. Check that all font weights are working correctly

## Font Usage in Code

The app now uses these semantic font styles:

### Main Header (Chubbo)
- `.appHeaderTitle` - 28pt Bold (for "Light After Loss")

### Headers (Excon)
- `.largeTitle` - 34pt Bold
- `.title1` - 28pt Bold  
- `.title2` - 22pt Bold
- `.title3` - 20pt SemiBold
- `.headline` - 17pt SemiBold
- `.subheadline` - 15pt Medium
- `.appTitle` - 24pt Bold
- `.tabTitle` - 18pt SemiBold
- `.cardTitle` - 16pt SemiBold

### Body Text (Ranade)
- `.body` - 17pt Regular
- `.callout` - 16pt Regular
- `.footnote` - 13pt Regular
- `.caption1` - 12pt Regular
- `.caption2` - 11pt Regular
- `.supportiveText` - 15pt Medium
- `.quoteText` - 15pt Medium
- `.buttonText` - 16pt Medium

## Notes

- All fonts will fallback to system fonts if custom fonts fail to load
- The FontExtensions.swift file provides easy access to both fonts
- Font weights are automatically mapped to available font files
- The app maintains the existing color scheme and spacing

## Troubleshooting

If fonts don't appear:

1. Check that font files are added to the app bundle
2. Verify Info.plist entries match actual font file names
3. Use FontLoader.loadFonts() to see what fonts are available
4. Check that font family names match what you're using in code