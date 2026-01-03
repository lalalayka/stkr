# Test Images for stkr

## How to add images to iOS Simulator:

### Method 1: Drag & Drop
1. Run the app in Simulator
2. Open Finder and locate test images
3. Drag images directly onto the Simulator window
4. Images will be saved to Photos app

### Method 2: Using Safari in Simulator
1. Open Safari in Simulator
2. Find images online or use a local web server
3. Long press on image → "Add to Photos"

### Method 3: Command Line
```bash
# Add images to simulator Photos library
xcrun simctl addmedia booted /path/to/your/image.jpg
```

### Method 4: Using Xcode
1. Window → Devices and Simulators
2. Select your simulator
3. Click the "..." button
4. Select "Add Photos..."
5. Choose your test images

## Recommended Test Images
- Landscape photos (e.g., 1920×1080)
- Portrait photos (e.g., 1080×1920)
- Square photos (e.g., 1080×1080)
- Different aspect ratios to test layout
