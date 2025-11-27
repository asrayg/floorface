# App Store Submission Guide for NoseTap

## Current Configuration

- **App Name**: FloorFace (Display Name: NoseTap)
- **Bundle Identifier**: `com.asray.reptap.FloorFace`
- **Marketing Version**: 1.0
- **Build Number**: 1
- **Minimum iOS Version**: 17.2
- **Development Team**: L6LUXM357X

## Pre-Submission Checklist

### ✅ 1. App Information
- [x] Bundle identifier configured
- [x] App version set (1.0)
- [x] Build number set (1)
- [x] Display name configured
- [ ] App icon (1024x1024) - Verify all sizes are present
- [x] Launch screen configured

### ✅ 2. Privacy & Permissions
- [x] Camera usage description updated
- [x] Notification usage description configured
- [ ] Privacy policy URL (if required for camera/notifications)

### ✅ 3. App Store Connect Setup

#### Required Information:
1. **App Name**: NoseTap
2. **Subtitle**: Track your daily pushups with nose taps
3. **Category**: Health & Fitness
4. **Age Rating**: 4+ (No objectionable content)
5. **Price**: Free

#### App Description (Suggested):
```
NoseTap makes tracking your daily pushups simple and fun. Just tap your nose on the screen to count each pushup!

Features:
• Simple nose-tap tracking - no complicated setup
• Weekly goal system with progress tracking
• Beautiful charts showing your weekly, monthly, and yearly progress
• Daily reminders to stay motivated
• Streak tracking to keep you consistent
• Share your progress charts with friends
• All data stored locally - your privacy is protected

Perfect for anyone looking to build a consistent pushup habit. Start small, track your progress, and watch yourself improve over time.
```

#### Keywords (Suggested):
pushups, fitness, workout, exercise, tracking, health, habit, daily, progress, charts, goals, motivation

#### Screenshots Needed:
- iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max)
- iPhone 6.5" (iPhone 11 Pro Max, XS Max)
- iPhone 5.5" (iPhone 8 Plus)
- iPad Pro 12.9" (if supporting iPad)

Screenshot ideas:
1. Capture screen showing live session
2. Stats page with weekly goal progress
3. Stats page with charts (weekly/monthly/yearly)
4. Settings page

### ✅ 4. Build Configuration

#### Before Archiving:
1. **Set Build Configuration to Release**
   - Product → Scheme → Edit Scheme
   - Set Build Configuration to "Release" for Archive

2. **Update Build Number**
   - Increment `CURRENT_PROJECT_VERSION` in project.pbxproj
   - Or set it in Xcode: Target → General → Build

3. **Verify Signing**
   - Target → Signing & Capabilities
   - Ensure "Automatically manage signing" is enabled
   - Select your development team

4. **Clean Build Folder**
   - Product → Clean Build Folder (Shift+Cmd+K)

### ✅ 5. Archive & Upload

1. **Create Archive**
   - Product → Archive
   - Wait for archive to complete

2. **Validate App**
   - In Organizer, select your archive
   - Click "Validate App"
   - Fix any issues that arise

3. **Distribute App**
   - Click "Distribute App"
   - Select "App Store Connect"
   - Choose "Upload"
   - Follow the wizard

### ✅ 6. App Store Connect Submission

1. **Create New App**
   - Go to App Store Connect
   - My Apps → + (New App)
   - Fill in:
     - Platform: iOS
     - Name: NoseTap
     - Primary Language: English
     - Bundle ID: com.asray.reptap.FloorFace
     - SKU: com.asray.reptap.FloorFace (or unique identifier)

2. **App Information**
   - Upload screenshots
   - Add description
   - Set category: Health & Fitness
   - Set age rating: 4+
   - Add keywords
   - Set support URL (if you have one)
   - Set marketing URL (optional)

3. **Pricing & Availability**
   - Set price: Free
   - Select availability: All countries (or specific)

4. **Version Information**
   - Upload build (after it processes)
   - Add "What's New" notes:
     ```
     Initial release of NoseTap! Track your daily pushups with simple nose taps on your screen. Set weekly goals, view your progress with beautiful charts, and build a consistent habit.
     ```

5. **Submit for Review**
   - Complete all required fields
   - Answer export compliance questions
   - Submit for review

## Important Notes

### Privacy Policy
If your app uses camera or notifications, you may need a privacy policy URL. Consider:
- Creating a simple privacy policy page
- Hosting it on GitHub Pages, your website, or a service like PrivacyPolicyGenerator

### Export Compliance
- Answer "No" to encryption questions (unless you're using encryption beyond standard HTTPS)
- The app uses standard iOS APIs only

### Testing
Before submitting:
- [ ] Test on physical device
- [ ] Test camera permissions flow
- [ ] Test notification permissions flow
- [ ] Test all features (capture, stats, settings, sharing)
- [ ] Test on different screen sizes
- [ ] Verify app icon appears correctly
- [ ] Verify launch screen displays correctly

### Common Issues

1. **Missing App Icon**: Ensure 1024x1024 icon is in AppIcon asset catalog
2. **Missing Screenshots**: Required for all device sizes you support
3. **Invalid Bundle ID**: Must match exactly in App Store Connect
4. **Version Conflicts**: Increment build number for each submission

## Next Steps

1. Update camera usage description (✅ Done)
2. Take screenshots on physical device or simulator
3. Create archive in Xcode
4. Upload to App Store Connect
5. Complete App Store listing
6. Submit for review

## Support

For issues during submission:
- Check [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Review [App Store Connect Help](https://help.apple.com/app-store-connect/)
- Check Xcode Organizer for validation errors

