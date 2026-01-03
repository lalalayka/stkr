//
//  CompositionViewModel.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import SwiftUI
import PhotosUI
import Combine

/// View model that manages composition state and operations
@MainActor
class CompositionViewModel: ObservableObject {
    @Published var state = CompositionState()
    
    // Canvas dimensions
    static let canvasWidth: CGFloat = 2160
    static let canvasHeight: CGFloat = 3840
    static let gapBetweenImages: CGFloat = 60  // points
    
    /// Add an image to the composition
    func addImage(assetId: String, width: CGFloat, height: CGFloat) {
        let selection = ImageSelection(assetId: assetId, width: width, height: height)
        state.addImage(selection)
    }
    
    /// Remove image at specific index
    func removeImage(at index: Int) {
        state.removeImage(at: index)
    }
    
    /// Replace image at specific index
    func replaceImage(at index: Int, assetId: String, width: CGFloat, height: CGFloat) {
        let newSelection = ImageSelection(assetId: assetId, width: width, height: height)
        state.replaceImage(at: index, with: newSelection)
    }
    
    /// Reorder images via drag and drop
    func moveImage(from source: Int, to destination: Int) {
        state.moveImage(from: source, to: destination)
    }
    
    /// Clear all selected images
    func clearAll() {
        state.clearAll()
    }
}
