//
//  ImageTile.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import SwiftUI
import PhotosUI

/// Individual image tile component with preview, replace, and remove actions
struct ImageTile: View {
    let imageSelection: ImageSelection
    let index: Int
    @Binding var activeTileId: String?
    let onReplace: () -> Void
    let onRemove: () -> Void
    
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    
    private var showActions: Bool {
        activeTileId == imageSelection.id
    }
    
    var body: some View {
        ZStack {
            // Image preview
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Color(.systemGray4)
            }
            
            // Drag handle (visible when overlay is hidden)
            if !showActions {
                HStack {
                    Spacer()
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(16)
                }
            }
            
            // Overlay with action buttons
            if showActions {
                Color.black.opacity(0.4)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeTileId = nil
                        }
                    }
                
                HStack(spacing: 0) {
                    Spacer()
                    Button(action: {
                        activeTileId = nil
                        onReplace()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title2)
                            Text("Replace")
                                .font(.caption)
                        }
                        .tint(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .accessibilityLabel("Replace image \(index + 1)")
                    
                    Button(action: {
                        activeTileId = nil
                        onRemove()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.title2)
                            Text("Remove")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
//                        .background(Color.red)
                        .tint(.red)
                    }
                    .accessibilityLabel("Remove image \(index + 1)")
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(imageSelection.aspectRatio, contentMode: .fit)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                activeTileId = (activeTileId == imageSelection.id) ? nil : imageSelection.id
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [imageSelection.assetId], options: nil).firstObject {
            // Target size for thumbnail preview (proportional to actual aspect ratio)
            let maxDimension: CGFloat = 2160 // Max height for preview
            let targetSize = CGSize(
                width: maxDimension * imageSelection.aspectRatio,
                height: maxDimension
            )
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                DispatchQueue.main.async {
                    self.uiImage = image
                    self.isLoading = false
                }
            }
        } else {
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var activeTileId: String? = nil
    let selection = ImageSelection(assetId: "test", width: 1080, height: 1920)
    ImageTile(
        imageSelection: selection,
        index: 0,
        activeTileId: $activeTileId,
        onReplace: { print("Replace") },
        onRemove: { print("Remove") }
    )
    .padding()
}
