//
//  CompositionState.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import Foundation

/// Represents the current composition state (selected images)
struct CompositionState: Equatable {
    private(set) var images: [ImageSelection] = []
    
    /// Maximum number of images that can be selected
    static let maxImages = 4
    
    /// Minimum number of images required for export
    static let minImages = 1
    
    /// Check if we can add more images
    var canAddMore: Bool {
        images.count < Self.maxImages
    }
    
    /// Check if composition is ready for export
    var canExport: Bool {
        images.count >= Self.minImages
    }
    
    /// Add an image to the composition
    mutating func addImage(_ image: ImageSelection) {
        guard canAddMore else { return }
        images.append(image)
    }
    
    /// Remove image at specific index
    mutating func removeImage(at index: Int) {
        guard index >= 0, index < images.count else { return }
        images.remove(at: index)
    }
    
    /// Replace image at specific index with new image
    mutating func replaceImage(at index: Int, with newImage: ImageSelection) {
        guard index >= 0, index < images.count else { return }
        images[index] = newImage
    }
    
    /// Reorder images by moving image from source to destination
    mutating func moveImage(from source: Int, to destination: Int) {
        guard source >= 0, source < images.count,
              destination >= 0, destination < images.count else { return }
        let movedImage = images.remove(at: source)
        images.insert(movedImage, at: destination)
    }
    
    /// Clear all images
    mutating func clearAll() {
        images.removeAll()
    }
}
