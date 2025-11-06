# Final Xcode Configuration Steps

I've cleaned up the file structure. Now you need to complete these steps **in Xcode**:

## ✅ What I've Done:
- Deleted auto-generated widget files (conflicts resolved)
- Organized file structure properly
- Models folder added to widget extension
- App Group entitlements configured correctly

## 🎯 What You Need to Do in Xcode:

### Step 1: Open the Project
Open: `/Users/kylepace/Dev Projects/beeminder_widget/beeminder_widget/beeminder_widget.xcodeproj`

### Step 2: Add Files to Targets (CRITICAL)

The files exist in the filesystem but need to be added to Xcode's targets.

#### For BeeminderGoal.swift:
1. Click on `Models/BeeminderGoal.swift` in left sidebar
2. Open **File Inspector** (right sidebar - press Cmd+Option+1)
3. Find **"Target Membership"** section
4. Check BOTH boxes:
   - ☑️ beeminder_widget
   - ☑️ BeeminderWidgetExtensionExtension

#### For BeeminderUser.swift:
1. Click on `Models/BeeminderUser.swift`
2. File Inspector → Target Membership
3. Check BOTH boxes:
   - ☑️ beeminder_widget
   - ☑️ BeeminderWidgetExtensionExtension

#### For BeeminderAPI.swift:
1. Click on `Services/BeeminderAPI.swift`
2. File Inspector → Target Membership
3. Check BOTH boxes:
   - ☑️ beeminder_widget
   - ☑️ BeeminderWidgetExtensionExtension

#### For DataStore.swift:
1. Click on `Services/DataStore.swift`
2. File Inspector → Target Membership
3. Check BOTH boxes:
   - ☑️ beeminder_widget
   - ☑️ BeeminderWidgetExtensionExtension

#### For App Files (ContentView.swift, GoalDetailView.swift, BeeminderWidgetApp.swift):
1. Select each file
2. File Inspector → Target Membership
3. Check ONLY:
   - ☑️ beeminder_widget
   - ☐ BeeminderWidgetExtensionExtension (UNCHECKED)

#### For BeeminderWidget.swift:
1. Click on `Widget/BeeminderWidget.swift`
2. File Inspector → Target Membership
3. Check ONLY:
   - ☐ beeminder_widget (UNCHECKED)
   - ☑️ BeeminderWidgetExtensionExtension

### Step 3: Clean and Build
1. **Product → Clean Build Folder** (Cmd+Shift+K)
2. **Product → Build** (Cmd+B)
3. Errors should be gone!

### Step 4: Run the App
1. Select scheme: **beeminder_widget** (top toolbar)
2. Select simulator: **iPhone 15 Pro** (or any iPhone)
3. Click **Play** button ▶️ (or Cmd+R)
4. App should launch and load your Beeminder goals!

### Step 5: Test the Widget
1. Once app is running, go to home screen (Cmd+Shift+H)
2. Long-press on empty space
3. Tap **+** button (top left)
4. Search for "Beeminder"
5. Select your widget
6. Choose size and add to home screen

## 🐛 Troubleshooting

### If you still see "Cannot find type 'BeeminderGoal'" errors:
- Double-check Target Membership for Model files
- Make sure BOTH targets are checked
- Clean build folder and rebuild

### If you see "multiple @main" errors:
- Make sure you deleted the auto-generated widget files
- Only BeeminderWidget.swift and BeeminderWidgetApp.swift should have @main

### If widget shows "Failed to load goals":
- Check that App Groups match in both targets
- Verify: `group.com.kylepace.beeminderwidget`
- Make sure entitlements files are properly set

## 📁 Current File Structure

```
beeminder_widget/
├── App/
│   ├── BeeminderWidgetApp.swift    (main app target only)
│   ├── ContentView.swift            (main app target only)
│   └── GoalDetailView.swift         (main app target only)
├── Models/
│   ├── BeeminderGoal.swift         (BOTH targets)
│   └── BeeminderUser.swift         (BOTH targets)
├── Services/
│   ├── BeeminderAPI.swift          (BOTH targets)
│   └── DataStore.swift             (BOTH targets)
└── Widget/
    └── BeeminderWidget.swift       (widget target only)

BeeminderWidgetExtensionExtension/
├── Models/
│   ├── BeeminderGoal.swift         (reference to main)
│   └── BeeminderUser.swift         (reference to main)
├── Services/
│   ├── BeeminderAPI.swift          (reference to main)
│   └── DataStore.swift             (reference to main)
└── Widget/
    └── BeeminderWidget.swift       (reference to main)
```

## ✨ Your Credentials Are Already Set!
- Username: kyle
- Auth Token: 9BErv46PRvNEbXPCMZDT
- App Group: group.com.kylepace.beeminderwidget

You're almost there! Just need to set the Target Membership in Xcode and you'll be good to go! 🚀
