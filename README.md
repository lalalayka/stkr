# STKR

A minimalist iOS app for creating vertical image compositions optimized for social media sharing.

## Overview

STKR enables users to select 1-4 images from their photo library, arrange them vertically with consistent spacing, and export as a single high-quality image perfect for Instagram Stories, TikTok, and other vertical social media formats.

## Features

- **Simple Selection**: Pick up to 4 images using the native iOS photo picker
- **Drag & Drop Reordering**: Long press any image to reorder with haptic feedback
- **Individual Controls**: Replace or remove any image in the composition
- **Smart Layout**: Images maintain their aspect ratios with proportional scaling
- **High-Quality Export**: Outputs 2160×3840 HEIC images at 95% quality
- **Direct Save**: Exports save directly to Photos with progress feedback
- **Dark Mode**: Permanent dark theme for distraction-free editing
- **Accessibility**: Full VoiceOver support with proper labels and tap targets

## Technical Details

- **Platform**: iOS (iPhone only)
- **Orientation**: Portrait only
- **Canvas**: 2160×3840 pixels with pure black background
- **Gap Size**: 60pt between images
- **Image Format**: HEIC output
- **Architecture**: SwiftUI with MVVM pattern
- **Frameworks**: Photos, PhotosUI, ImageIO

## Permissions

The app requires access to your photo library to:
- Select images for composition
- Save exported images to Photos

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+

## Project Structure

```
stkr/
├── Views/              # UI components
├── ViewModels/         # State management
├── Models/             # Data structures
├── Utilities/          # Image processing
├── Coordinators/       # UIKit bridges
└── Assets.xcassets/    # App assets
```

## License

Copyright © 2026 Sergey Kovalchuk. All rights reserved.
