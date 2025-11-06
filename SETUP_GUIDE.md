# Beeminder Widget App - Complete Setup Guide

This guide will walk you through setting up your iOS Beeminder widget app in Xcode.

## Prerequisites

- macOS computer
- Xcode 15 or later (free from Mac App Store)
- Beeminder account and API credentials
- iOS device or simulator for testing

## Step 1: Install Xcode

1. Open Mac App Store
2. Search for "Xcode"
3. Click "Get" or "Install"
4. Wait for installation (it's large, ~10GB)

## Step 2: Get Your Beeminder Credentials

1. Log in to Beeminder.com
2. Visit: https://www.beeminder.com/api/v1/auth_token.json
3. Save your `username` and `auth_token` (you'll need these later)

## Step 3: Create Xcode Project

### 3.1 Create the Main App

1. Open Xcode
2. **File → New → Project**
3. Choose **iOS** tab → **App** → Click **Next**
4. Fill in project details:
   - **Product Name**: `BeeminderWidget`
   - **Team**: Select your Apple ID (or "None" for simulator-only)
   - **Organization Identifier**: `com.yourname` (use your name or company)
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: Core Data - **UNCHECKED**
   - **Tests**: **UNCHECKED** (optional)
5. Click **Next**
6. Choose `/Users/kylepace/BeeminderWidget` as the location
7. Click **Create**

### 3.2 Add Widget Extension

1. **File → New → Target**
2. Choose **iOS** tab → **Widget Extension** → Click **Next**
3. Fill in:
   - **Product Name**: `BeeminderWidgetExtension`
   - **Include Configuration Intent**: **UNCHECK this box**
4. Click **Finish**
5. When prompted "Activate 'BeeminderWidgetExtension' scheme?", click **Activate**

## Step 4: Configure App Groups

App Groups allow the main app and widget to share data.

### 4.1 Enable App Groups for Main App

1. In Xcode's left sidebar, click the **project icon** (top blue icon)
2. Select **BeeminderWidget** target (under TARGETS)
3. Click **Signing & Capabilities** tab
4. Click **+ Capability** button
5. Search for and add **App Groups**
6. Click the **+** button under App Groups
7. Enter: `group.com.yourname.beeminderwidget` (replace "yourname" with your actual name/identifier)
8. Press Enter

### 4.2 Enable App Groups for Widget Extension

1. Stay in the same project settings view
2. Select **BeeminderWidgetExtension** target from the TARGETS list
3. Click **Signing & Capabilities** tab
4. Click **+ Capability** button
5. Add **App Groups**
6. Check the box next to: `group.com.yourname.beeminderwidget` (same as before)

## Step 5: Add Source Files

### 5.1 Delete Default Files

1. In the left sidebar, find and delete these auto-generated files:
   - `ContentView.swift` (in BeeminderWidget folder)
   - `BeeminderWidgetExtension.swift` (in BeeminderWidgetExtension folder)
   - `BeeminderWidgetExtensionLiveActivity.swift` (if exists)
2. Choose **Move to Trash** when prompted

### 5.2 Create Folder Structure

1. Right-click **BeeminderWidget** folder in sidebar
2. Choose **New Group** → Name it `Models`
3. Repeat to create: `Services`, `App`, `Widget`

### 5.3 Add Files to Project

Now add all the Swift files from the `/Users/kylepace/BeeminderWidget/` directory:

#### Models (add to both targets)
1. **File → Add Files to "BeeminderWidget"**
2. Navigate to `Models` folder
3. Select `BeeminderGoal.swift` and `BeeminderUser.swift`
4. **IMPORTANT**: Check both:
   - ☑️ BeeminderWidget target
   - ☑️ BeeminderWidgetExtension target
5. Click **Add**
6. Drag them into the `Models` group in the sidebar

#### Services (add to both targets)
1. **File → Add Files to "BeeminderWidget"**
2. Navigate to `Services` folder
3. Select `BeeminderAPI.swift` and `DataStore.swift`
4. **Check both targets**
5. Click **Add**
6. Drag them into the `Services` group

#### App Files (main target only)
1. **File → Add Files to "BeeminderWidget"**
2. Navigate to `App` folder
3. Select all three files:
   - `BeeminderWidgetApp.swift`
   - `ContentView.swift`
   - `GoalDetailView.swift`
4. **Check only**: ☑️ BeeminderWidget target
5. Click **Add**
6. Drag them into the `App` group

**IMPORTANT**: Delete the original `BeeminderWidgetApp.swift` that Xcode created, and use the new one you just added.

#### Widget Files (widget target only)
1. **File → Add Files to "BeeminderWidget"**
2. Navigate to `Widget` folder
3. Select `BeeminderWidget.swift`
4. **Check only**: ☑️ BeeminderWidgetExtension target
5. Click **Add**
6. Drag it into the `Widget` group

## Step 6: Update Configuration

### 6.1 Update App Group ID

1. Open `DataStore.swift`
2. Find line: `private let appGroupID = "group.com.yourname.beeminderwidget"`
3. Change to match YOUR App Group ID from Step 4

### 6.2 Add Your Beeminder Credentials

**Option A: Hardcode (for testing only)**
1. Open `BeeminderAPI.swift`
2. Find line: `init(username: String = "YOUR_USERNAME", authToken: String = "YOUR_AUTH_TOKEN")`
3. Replace with your actual credentials:
   ```swift
   init(username: String = "your_actual_username", authToken: String = "your_actual_token")
   ```

**Option B: Use Settings (recommended)**
- Leave the defaults
- You'll enter credentials in the app's Settings screen after launching

## Step 7: Build and Run

### 7.1 Run Main App

1. Select **BeeminderWidget** scheme (top toolbar near center)
2. Choose a simulator (e.g., "iPhone 15 Pro")
3. Click the **Play** button (▶️) or press **Cmd+R**
4. Wait for build to complete
5. App should launch in simulator
6. Tap **Settings** gear icon
7. Enter your Beeminder username and auth token
8. Tap **Save Credentials**
9. Pull down to refresh - your goals should load!

### 7.2 Add Widget to Home Screen

1. While simulator is running, press **Cmd+Shift+H** (or click Home button)
2. Long-press on empty space on home screen
3. Tap **+** button (top left)
4. Search for "Beeminder"
5. Select **BeeminderWidget**
6. Choose size (Small, Medium, or Large)
7. Tap **Add Widget**
8. Tap **Done**

## Troubleshooting

### "Build Failed" Errors

**Missing targets for files:**
- Right-click the file → **Show File Inspector** (right sidebar)
- Check the correct target boxes under **Target Membership**

**Duplicate symbols:**
- Make sure you deleted the original auto-generated files

**App Group not found:**
- Verify App Group ID matches in both targets
- Check DataStore.swift has the correct ID

### Widget Not Updating

1. Make sure App Groups are configured correctly
2. Verify both targets use the SAME App Group ID
3. In simulator, delete widget and re-add it
4. Check credentials are saved in app settings

### "Failed to load goals" Error

1. Verify your Beeminder credentials are correct
2. Check you have internet connection
3. Visit https://www.beeminder.com/api/v1/auth_token.json to confirm token
4. Look at Xcode console for detailed error messages

### API Request Issues

1. Open Xcode console (bottom panel)
2. Look for error messages
3. Common issues:
   - Invalid auth token
   - Incorrect username
   - Network connectivity
   - Beeminder API might be down

## Next Steps

### Features to Add

- [ ] Multiple widget configurations (different goals)
- [ ] Add datapoints directly from widget
- [ ] Lock screen widgets (iOS 16+)
- [ ] Live Activities for derailing goals
- [ ] Push notifications for approaching deadlines
- [ ] Goal filtering and favorites
- [ ] Dark mode custom styling
- [ ] iPad support

### Publishing to App Store

1. Join Apple Developer Program ($99/year)
2. Create App ID in Apple Developer portal
3. Set up proper code signing
4. Create app icons (required sizes)
5. Take screenshots
6. Create App Store listing
7. Submit for review

## Resources

- [Beeminder API Documentation](https://api.beeminder.com/)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [App Groups Guide](https://developer.apple.com/documentation/xcode/configuring-app-groups)

## Support

If you encounter issues:
1. Check Xcode console for errors
2. Verify all configuration steps
3. Try cleaning build: **Product → Clean Build Folder** (Cmd+Shift+K)
4. Restart Xcode
5. Delete derived data: **Xcode → Preferences → Locations → Derived Data → Arrow icon**

Good luck with your Beeminder widget app! 🎯
