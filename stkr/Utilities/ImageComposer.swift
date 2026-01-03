//
//  ImageComposer.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import Foundation
import UIKit
import Photos
import ImageIO

/// Utility for composing multiple images into a single HEIC output
class ImageComposer {
    static let backgroundColor = UIColor.black
    
    enum ComposerError: LocalizedError {
        case failedToLoadAsset
        case failedToGenerateImage
        case failedToExportHEIC
        
        var errorDescription: String? {
            switch self {
            case .failedToLoadAsset:
                return "Failed to load image from Photos library"
            case .failedToGenerateImage:
                return "Failed to generate composed image"
            case .failedToExportHEIC:
                return "Failed to export image as HEIC"
            }
        }
    }
    
    /// Compose multiple images into a single HEIC image
    /// - Parameters:
    ///   - imageSelections: Array of ImageSelection objects with asset IDs
    ///   - completion: Callback with result (UIImage or Error)
    static func compose(imageSelections: [ImageSelection], completion: @escaping (Result<Data, ComposerError>) -> Void) {
        // Load all images asynchronously
        loadImages(for: imageSelections) { result in
            switch result {
            case .success(let uiImages):
                // Generate the composed image
                if let composedImage = generateComposedImage(from: uiImages, selections: imageSelections) {
                    // Export to HEIC
                    if let heicData = exportToHEIC(composedImage) {
                        completion(.success(heicData))
                    } else {
                        completion(.failure(.failedToExportHEIC))
                    }
                } else {
                    completion(.failure(.failedToGenerateImage))
                }
            case .failure:
                completion(.failure(.failedToLoadAsset))
            }
        }
    }
    
    /// Load UIImage objects from PHAsset identifiers
    private static func loadImages(for imageSelections: [ImageSelection], completion: @escaping (Result<[UIImage], ComposerError>) -> Void) {
        var loadedImages: [UIImage] = []
        var errors: [Error] = []
        let dispatchGroup = DispatchGroup()
        
        for selection in imageSelections {
            dispatchGroup.enter()
            
            if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [selection.assetId], options: nil).firstObject {
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                options.deliveryMode = .highQualityFormat
                
                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFit,
                    options: options
                ) { image, _ in
                    if let image = image {
                        loadedImages.append(image)
                    }
                    dispatchGroup.leave()
                }
            } else {
                errors.append(ComposerError.failedToLoadAsset)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if errors.isEmpty && loadedImages.count == imageSelections.count {
                completion(.success(loadedImages))
            } else {
                completion(.failure(.failedToLoadAsset))
            }
        }
    }
    
    /// Generate the composed image with scaled images and black background
    private static func generateComposedImage(from images: [UIImage], selections: [ImageSelection]) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: CompositionViewModel.canvasWidth, height: CompositionViewModel.canvasHeight)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        // Fill black background
        backgroundColor.setFill()
        UIRectFill(rect)
        
        // Calculate layout using ViewModel logic to ensure consistency with preview
        let layout = calculateLayoutForSelections(selections)
        
        for (index, image) in images.enumerated() {
            let (scaledWidth, scaledHeight, yOffset) = layout[index]
            
            // Center horizontally
            let xOffset = (CompositionViewModel.canvasWidth - scaledWidth) / 2
            let drawRect = CGRect(x: xOffset, y: yOffset, width: scaledWidth, height: scaledHeight)
            
            image.draw(in: drawRect)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Calculate layout for ImageSelections using same algorithm as Canvas VStack
    private static func calculateLayoutForSelections(_ selections: [ImageSelection]) -> [(width: CGFloat, height: CGFloat, yOffset: CGFloat)] {
        guard !selections.isEmpty else { return [] }
        
        let imageCount = selections.count
        let totalGapHeight = CGFloat(imageCount - 1) * CompositionViewModel.gapBetweenImages
        let availableHeight = CompositionViewModel.canvasHeight - totalGapHeight
        
        var layouts: [(width: CGFloat, height: CGFloat, yOffset: CGFloat)] = []
        
        // First pass: calculate ideal heights for all images
        var idealHeights: [CGFloat] = []
        var totalIdealHeight: CGFloat = 0
        
        for selection in selections {
            let aspectRatio = selection.aspectRatio
            // Try to fit width first
            let widthBasedHeight = CompositionViewModel.canvasWidth / aspectRatio
            idealHeights.append(widthBasedHeight)
            totalIdealHeight += widthBasedHeight
        }
        
        // Calculate scale factor to fit all images in available height
        let scaleFactor = totalIdealHeight > availableHeight ? availableHeight / totalIdealHeight : 1.0
        
        // Calculate total height used
        var totalUsedHeight: CGFloat = 0
        for height in idealHeights {
            totalUsedHeight += height * scaleFactor
        }
        totalUsedHeight += totalGapHeight
        
        // Center vertically
        var currentY = (CompositionViewModel.canvasHeight - totalUsedHeight) / 2
        
        // Second pass: apply scale and create layout
        for (index, selection) in selections.enumerated() {
            let aspectRatio = selection.aspectRatio
            let finalHeight = idealHeights[index] * scaleFactor
            let finalWidth = finalHeight * aspectRatio
            
            layouts.append((width: finalWidth, height: finalHeight, yOffset: currentY))
            currentY += finalHeight
            
            // Add gap after each image except the last
            if index < imageCount - 1 {
                currentY += CompositionViewModel.gapBetweenImages
            }
        }
        
        return layouts
    }
    
    /// Export UIImage to HEIC data
    private static func exportToHEIC(_ image: UIImage) -> Data? {
        guard let cgImage = image.cgImage else { return nil }
        
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, AVFileType.heic.rawValue as CFString, 1, nil) else {
            return nil
        }
        
        let options: [String: Any] = [
            kCGImageDestinationLossyCompressionQuality as String: 0.95
        ]
        
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        
        return data as Data
    }
}
