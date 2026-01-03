# iOS App Developer Brief

Project: Vertical Image Composer for Social Media
Platform: iOS
Target: iPhone (portrait only)

## App Goal (Single Primary Job)
Enable users to select up to 4 images, arrange them vertically, and export a single 1080×1920 HEIC image suitable for social media sharing.

## Core User Flow
1. User launches app
2. User selects 1–4 images from Photos
3. Selected images appear in a vertical list
4. User can:
4.1 Reorder images via drag & drop
4.2 Replace a single image
4.3 Remove a single image
4.4 Remove all images and start over
5. User taps Export
6. App generates a 1080×1920 HEIC image
7. System Share Sheet is presented


## Functional Requirements
### Image Selection
- Use system photo picker
- Allow multiple selection
- Enforce maximum of 4 images
- Minimum: 1 image required to export

### Image Management
- Selected images displayed in a vertical stack
- Each image tile supports:
  - Replace action (reopens photo picker for that slot)
  - Remove action (deletes that image only)
- Global action:
  - “Remove all” resets app to initial state

### Reordering
- Drag-and-drop reordering via long-press
- Visual feedback during drag (lifted tile, shadow, scale)
- Order updates immediately and persists until export/reset

### Output Specifications
- Resolution: 1080 × 1920 pixels
- Orientation: Portrait
- Format: HEIC
- Color space: Default iOS

### Sharing
- After export, present iOS system Share Sheet
- No in-app gallery or history required
- No automatic saving unless user selects it from Share Sheet

### UI / UX Requirements
[Link to Figma with design](https://www.figma.com/design/AxeCnUvKalTtzK2mm27KHq/stkr?node-id=0-1&p=f&m=dev)

### Accessibility
- Standard iOS components where possible
- Large tap targets
- VoiceOver labels for buttons and image tiles

### Permissions
- Photos access required
- Use standard iOS permission flow
- If denied:
  - Show explanation
  - Provide link to system Settings
  - ([Figma with design](https://www.figma.com/design/AxeCnUvKalTtzK2mm27KHq/stkr?node-id=15-909&t=njRpBeBnM4GuRcLE-11))

### Technical Notes (Non-Prescriptive)
- Swift + SwiftUI recommended
- Native drag-and-drop APIs preferred
- Use native image rendering pipeline for HEIC export
- Performance optimized for up to 4 high-resolution photos