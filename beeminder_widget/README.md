# Beeminder Widget App

An iOS app with home screen widgets to track your Beeminder goals.

## Setup Instructions

### 1. Create New Xcode Project
1. Open Xcode
2. File → New → Project
3. Choose "iOS" → "App"
4. Product Name: `BeeminderWidget`
5. Interface: SwiftUI
6. Language: Swift
7. Save to this directory

### 2. Add Widget Extension
1. File → New → Target
2. Choose "Widget Extension"
3. Product Name: `BeeminderWidgetExtension`
4. Include Configuration Intent: NO (for now)
5. Activate scheme when prompted

### 3. Enable App Groups
1. Select project in navigator
2. Select "BeeminderWidget" target
3. Go to "Signing & Capabilities"
4. Click "+ Capability" → "App Groups"
5. Add group: `group.com.yourname.beeminderwidget`
6. Repeat for "BeeminderWidgetExtension" target

### 4. Add Files to Project
- Copy all .swift files from this directory into your Xcode project
- Make sure to add shared files to both targets (app + widget)

## Beeminder API

You'll need your Beeminder auth token from:
https://www.beeminder.com/api/v1/auth_token.json

## File Structure

```
BeeminderWidget/
├── App/
│   ├── BeeminderWidgetApp.swift      # App entry point
│   ├── ContentView.swift              # Main app UI
│   └── GoalDetailView.swift           # Individual goal view
├── Models/
│   ├── BeeminderGoal.swift            # Goal data model
│   └── BeeminderUser.swift            # User data model
├── Services/
│   ├── BeeminderAPI.swift             # API client
│   └── DataStore.swift                # Shared data storage
└── Widget/
    ├── BeeminderWidget.swift          # Widget definition
    └── BeeminderWidgetEntryView.swift # Widget UI
```

## Next Steps

1. Get your Beeminder auth token
2. Replace "YOUR_USERNAME" and "YOUR_AUTH_TOKEN" in BeeminderAPI.swift
3. Build and run in Xcode
4. Add widget to home screen from widget gallery
