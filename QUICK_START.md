# Quick Start: App Store Submission

## Immediate Steps

### 1. Verify App Icon
```bash
# Check that 1024x1024 icon exists
ls FloorFace/Assets.xcassets/AppIcon.appiconset/FloorFace_AppStore.png
```

### 2. Update Build Number (Before Each Submission)
In Xcode:
- Select project in navigator
- Select "FloorFace" target
- Go to "General" tab
- Increment "Build" number (currently: 1)

Or edit `project.pbxproj`:
- Find `CURRENT_PROJECT_VERSION = 1;`
- Change to `CURRENT_PROJECT_VERSION = 2;` (or next number)

### 3. Create Archive
1. In Xcode: Product → Scheme → Edit Scheme
2. Set "Archive" build configuration to "Release"
3. Product → Archive
4. Wait for archive to complete

### 4. Validate & Upload
1. Window → Organizer (or Product → Archive)
2. Select your archive
3. Click "Validate App"
4. Fix any issues
5. Click "Distribute App"
6. Select "App Store Connect"
7. Follow the wizard

### 5. App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Create new app (if first time)
3. Upload screenshots
4. Fill in description
5. Submit for review

## Current Settings
- **Bundle ID**: `com.asray.reptap.FloorFace`
- **Version**: 1.0
- **Build**: 1 (increment before each submission)
- **Team**: L6LUXM357X
- **Min iOS**: 17.2

## Screenshot Sizes Needed
- iPhone 6.7": 1290 x 2796 pixels
- iPhone 6.5": 1242 x 2688 pixels  
- iPhone 5.5": 1242 x 2208 pixels
- iPad Pro 12.9": 2048 x 2732 pixels

## Quick Test Before Submission
- [ ] App launches without crashes
- [ ] Camera permission works
- [ ] Notification permission works
- [ ] Pushup counting works
- [ ] Charts display correctly
- [ ] Share functionality works
- [ ] App icon visible on home screen
- [ ] Launch screen displays

