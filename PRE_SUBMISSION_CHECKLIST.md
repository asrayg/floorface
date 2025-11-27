# Pre-Submission Checklist

## ✅ Configuration (Auto-checked)

- [x] Bundle identifier: `com.asray.reptap.FloorFace`
- [x] Marketing version: 1.0
- [x] Build number: 1 (increment before submission)
- [x] App icon 1024x1024: ✅ Present
- [x] Launch screen: ✅ Configured
- [x] Camera permission description: ✅ Updated
- [x] Notification permission description: ✅ Configured
- [x] Minimum iOS version: 17.2

## 📱 Manual Checks Required

### Before Archiving:
- [ ] **Increment Build Number** (currently 1, change to 2 for first submission)
- [ ] **Set Archive Scheme to Release**
  - Product → Scheme → Edit Scheme → Archive → Build Configuration → Release
- [ ] **Verify Signing**
  - Target → Signing & Capabilities
  - Team: L6LUXM357X
  - "Automatically manage signing" enabled
- [ ] **Clean Build Folder**
  - Product → Clean Build Folder (Shift+Cmd+K)

### Testing on Device:
- [ ] App launches successfully
- [ ] Camera permission prompt appears and works
- [ ] Notification permission prompt appears and works
- [ ] Pushup counting works correctly
- [ ] Session start/end works
- [ ] Stats page displays correctly
- [ ] Charts render properly (weekly/monthly/yearly)
- [ ] Share functionality works
- [ ] Settings page functions correctly
- [ ] Weekly goal updates work
- [ ] App icon appears on home screen
- [ ] Launch screen displays correctly

### Screenshots Needed:
- [ ] iPhone 6.7" (1290 x 2796) - Capture screen
- [ ] iPhone 6.7" (1290 x 2796) - Stats screen
- [ ] iPhone 6.7" (1290 x 2796) - Settings screen
- [ ] iPhone 6.5" (1242 x 2688) - Same screens
- [ ] iPhone 5.5" (1242 x 2208) - Same screens
- [ ] iPad Pro 12.9" (2048 x 2732) - If supporting iPad

**Screenshot Tips:**
- Use Simulator: Device → Screenshot
- Or use physical device: Volume Up + Power button
- Show the best features in screenshots
- Make sure UI looks polished

### App Store Connect:
- [ ] Create app listing
- [ ] Upload screenshots
- [ ] Write app description
- [ ] Add keywords
- [ ] Set category: Health & Fitness
- [ ] Set age rating: 4+
- [ ] Set price: Free
- [ ] Add "What's New" notes for version 1.0
- [ ] Privacy policy URL (if required)

### Final Steps:
- [ ] Archive the app (Product → Archive)
- [ ] Validate the archive
- [ ] Upload to App Store Connect
- [ ] Wait for processing (can take 10-30 minutes)
- [ ] Complete app listing in App Store Connect
- [ ] Submit for review

## Common Issues & Solutions

### Issue: "Missing App Icon"
**Solution**: Verify `FloorFace_AppStore.png` exists in AppIcon.appiconset

### Issue: "Invalid Bundle Identifier"
**Solution**: Ensure bundle ID in Xcode matches App Store Connect exactly

### Issue: "Missing Screenshots"
**Solution**: Upload screenshots for all required device sizes

### Issue: "Export Compliance"
**Solution**: Answer "No" to encryption questions (standard iOS APIs only)

### Issue: "Privacy Policy Required"
**Solution**: If prompted, create a simple privacy policy and host it online

## Ready to Submit?

Once all items above are checked:
1. Archive in Xcode
2. Upload to App Store Connect
3. Complete listing
4. Submit for review

**Review time**: Typically 24-48 hours, can take up to 7 days

