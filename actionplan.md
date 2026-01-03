# Action Plan: Vertical Image Composer for iOS

**Last Updated:** 2 January 2026

---

## Project Overview
Build a stateless iOS app that enables users to select 1–4 images, arrange them vertically with a 10pt black gap, and export as a single 1080×1920 HEIC image for social media sharing.

**Key Constraints:**
- Canvas: 1080×1920 px, pure black background (#000000)
- Gaps: 10pt between images, images preserve aspect ratio
- Stateless: No draft persistence, reset on close
- Photo Picker: System default, all Photos, no filtering
- Input: Accept any resolution and file format

---

## Phase 1: Architecture & Data Models

### 1.1 Data Models
- [ ] Create `ImageSelection` struct (selected photo + metadata)
- [ ] Create `CompositionState` (array of selected images, up to 4)
- [ ] Define image metadata: PHAsset reference, original dimensions, selected for composition

### 1.2 View Model
- [ ] `CompositionViewModel`: manages state (selection, reordering, removal)
  - Add image
  - Remove image by index
  - Replace image at index
  - Reorder images (drag-drop support)
  - Clear all images
  - Calculate layout for preview (scale to fit 1080×1920 with 10pt gaps)

### 1.3 Image Processing Utility
- [ ] `ImageComposer` class:
  - Load PHAsset into UIImage
  - Calculate scaled dimensions (preserve aspect ratio, fit 1080×1920 with gaps)
  - Render final HEIC image (1080×1920, black background, 10pt gaps)

---

## Phase 2: UI/UX Implementation

### 2.1 Main Content View Structure
- [ ] **Initial State (Empty)**
  - Large "Select Images" button
  - Explanatory text (e.g., "Choose 1–4 images")
  
- [ ] **Selection State (1–4 images)**
  - Vertical scroll view with selected images
  - Each image tile shows:
    - Image preview (scaled proportionally)
    - Replace button (icon/swipe action)
    - Remove button (icon/swipe action)
    - Drag handle for reordering
  - "Export" button (enabled if ≥1 image selected)
  - "Remove All" button

### 2.2 Image Selection Flow
- [ ] Integrate `PHPickerViewController`
  - Trigger on "Select Images" / "Add More" button tap
  - Allow multi-select up to 4 images total
  - Handle user cancellation gracefully

### 2.3 Image Tiles & Interactions
- [ ] Implement reorderable vertical list
  - Drag-and-drop via `onMoveCommand()` or custom gesture
  - Visual feedback: scale/shadow on drag
  - Drop and update order in state
  
- [ ] Replace action (per-tile)
  - Present photo picker scoped to that slot only
  - Swap out old image with new selection
  
- [ ] Remove action (per-tile)
  - Delete image at index
  - Reflow remaining images

### 2.4 Permissions Handling
- [ ] Request Photos permission on app launch
- [ ] If denied:
  - Show alert with explanation
  - Provide "Open Settings" button linking to app settings
  - Block image selection UI

---

## Phase 3: Export & Sharing

### 3.1 Image Composition Engine
- [ ] `ImageComposer.compose()`:
  - Input: array of UIImage, target canvas size (1080×1920)
  - Calculate layout:
    - Total height available: 1920 px
    - Reserved for gaps: (n-1) × 10 px (n = image count)
    - Available for images: 1920 - gaps
    - Scale each image proportionally to fit width (1080 px)
    - Distribute remaining vertical space or apply constraints
  - Render to `UIImage` with black background
  - Convert to HEIC format

### 3.2 Export & Share Sheet
- [ ] Trigger export on "Export" button tap
  - Generate HEIC in memory (or temp file)
  - Present `UIActivityViewController` (system Share Sheet)
  - Options: Save to Photos, Mail, Messages, Files, etc.

### 3.3 Post-Export Cleanup
- [ ] After share sheet dismissal:
  - Return to app (stateless, so no state preservation needed)
  - User may select new images or close app

---

## Phase 4: Testing

### 4.1 Unit Tests
- [ ] `CompositionViewModel` tests
  - Add/remove/replace images
  - Reorder operations
  - Max 4 image enforcement
  
- [ ] `ImageComposer` tests
  - Layout calculations (scaling, gaps, aspect ratios)
  - HEIC generation

### 4.2 Integration Tests
- [ ] Photo picker flow (mock PHPicker)
- [ ] Drag-and-drop reordering
- [ ] Export and share flow

### 4.3 Manual Testing
- [ ] Test with 1, 2, 3, 4 images (various aspect ratios)
- [ ] Test replace and remove operations
- [ ] Verify HEIC output dimensions (1080×1920)
- [ ] Verify black background and 10pt gaps
- [ ] Test permissions flow (denied/granted)
- [ ] Test on different devices (iPhone SE, iPhone 15 Pro)

---

## Phase 5: Polish & Accessibility

### 5.1 Accessibility
- [ ] VoiceOver labels for all buttons and image tiles
- [ ] Large tap targets (minimum 44×44 pt)
- [ ] High contrast for UI elements
- [ ] Test with Accessibility Inspector

### 5.2 Visual Polish
- [ ] Match Figma design system
- [ ] Smooth animations for drag-drop
- [ ] Loading states during image selection/export
- [ ] Error handling (corrupted images, memory issues)

### 5.3 Performance
- [ ] Optimize image loading (thumbnail previews in list)
- [ ] Lazy load full-res images only at export time
- [ ] Memory management for large photos

---

## Phase 6: Deployment

### 6.1 Final Checks
- [ ] Code review
- [ ] Test on physical devices
- [ ] Verify all permissions and info.plist entries
- [ ] App Store compliance review

### 6.2 Release
- [ ] Build production target
- [ ] Archive and upload to App Store Connect
- [ ] Fill in app details (description, keywords, screenshots)
- [ ] Submit for review

---

## Implementation Priority Order

**High Priority (Core Flow):**
1. Data models & view model (Phase 1)
2. Main UI scaffold (Phase 2.1–2.2)
3. Image picker integration (Phase 2.2)
4. Image composition engine (Phase 3.1)
5. Export & share sheet (Phase 3.2)

**Medium Priority (Polish):**
6. Reordering UI & interactions (Phase 2.3–2.4)
7. Permissions handling (Phase 2.4)
8. Visual refinements (Phase 5.2)

**Low Priority (Quality):**
9. Unit tests (Phase 4.1)
10. Accessibility (Phase 5.1)
11. Performance optimization (Phase 5.3)

---

## Technical Stack
- **Language:** Swift
- **UI Framework:** SwiftUI
- **Image Handling:** UIImage, PHPickerViewController, Core Image
- **Export:** Image I/O (for HEIC)
- **Testing:** XCTest

---

## Open Questions / Risks
- **Memory Usage:** Very large images (e.g., 12MP+) loaded simultaneously—may need streaming or downsampling strategy.
- **HEIC Compatibility:** Ensure iOS version supports HEIC export (iOS 11+).
- **Layout Constraints:** If images have vastly different aspect ratios, resulting composition may have unexpected whitespace. Consider documenting expected behavior.

