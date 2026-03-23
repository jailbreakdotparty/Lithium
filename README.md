# Lithium
**A basic and limited customization tool for iOS 16.0 and above, using only MDM configuration profiles.**

## What exactly does this do?
This is basically an on-device profile generator that's centered around features and toggles inside of various [MDM-based payloads](https://developer.apple.com/documentation/devicemanagement) that would be good for legitmate customization.

## How do I use this tool?
You're gonna need to supervise your device beforehand for these profiles to install, which is pretty easy with [Nugget](https://github.com/leminlimez/Nugget). If you've done DelayOTAs before, then you're probably familiar with the process. **Do NOT use this tool if you have a device that's managed by an organization (has MDM enabled!).**

## Tweaks/Features
- Restriction Toggles: Allows you to disable features that you wouldn't normally be able to disable in iOS.
- App Notifications: Blocks notifications COMPLETELY for the apps that you choose. This could be useful if you don't like the Shortcuts notification popup telling you that automations are enabled, for example.
- Blocked Applications: Removes apps of your choice from all places on the device without deleting them.
- Lockscreen Footnotes: Adds a custom label to the bottom of your lockscreen. Looks and functions exactly like the footnote feature inside of Nugget.
