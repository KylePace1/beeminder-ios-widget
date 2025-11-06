# Target Membership Checklist

Use this to verify your target membership settings in Xcode.

## Files that should be in MAIN APP TARGET ONLY (beeminder_widget)

Click each file and verify Target Membership shows ONLY beeminder_widget:

- [ ] App/BeeminderWidgetApp.swift
  - ☑️ beeminder_widget
  - ☐ BeeminderWidgetExtensionExtension (MUST BE UNCHECKED)

- [ ] App/ContentView.swift
  - ☑️ beeminder_widget
  - ☐ BeeminderWidgetExtensionExtension (MUST BE UNCHECKED)

- [ ] App/GoalDetailView.swift
  - ☑️ beeminder_widget
  - ☐ BeeminderWidgetExtensionExtension (MUST BE UNCHECKED)

## Files that should be in WIDGET EXTENSION TARGET ONLY (BeeminderWidgetExtensionExtension)

Click this file and verify Target Membership shows ONLY BeeminderWidgetExtensionExtension:

- [ ] Widget/BeeminderWidget.swift
  - ☐ beeminder_widget (MUST BE UNCHECKED)
  - ☑️ BeeminderWidgetExtensionExtension

## Files that should be in BOTH TARGETS

Click each file and verify Target Membership shows BOTH targets:

- [ ] Models/BeeminderGoal.swift
  - ☑️ beeminder_widget
  - ☑️ BeeminderWidgetExtensionExtension

- [ ] Models/BeeminderUser.swift
  - ☑️ beeminder_widget
  - ☑️ BeeminderWidgetExtensionExtension

- [ ] Services/BeeminderAPI.swift
  - ☑️ beeminder_widget
  - ☑️ BeeminderWidgetExtensionExtension

- [ ] Services/DataStore.swift
  - ☑️ beeminder_widget
  - ☑️ BeeminderWidgetExtensionExtension

---

## How to Fix Incorrect Target Membership:

1. Click the file in left sidebar
2. Open File Inspector (right sidebar, Cmd+Option+1)
3. Scroll to "Target Membership"
4. To ADD a target: Click "+" button, select target, click Save
5. To REMOVE a target: Click "-" button next to that target

## After Fixing All Files:

1. Product → Clean Build Folder (Cmd+Shift+K)
2. Product → Build (Cmd+B)
3. Run the app (Cmd+R)

---

The key issue causing the "'main' attribute can only apply to one type" error:

**BeeminderWidget.swift is in BOTH targets when it should ONLY be in BeeminderWidgetExtensionExtension**

Fix: Remove it from beeminder_widget target!
