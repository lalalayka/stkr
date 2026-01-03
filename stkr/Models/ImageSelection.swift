//
//  ImageSelection.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import Foundation
import PhotosUI

/// Represents a single selected image with metadata
struct ImageSelection: Identifiable, Equatable {
    let id: String
    let assetId: String  // PHAsset identifier
    let originalWidth: CGFloat
    let originalHeight: CGFloat
    
    /// Aspect ratio of the original image
    var aspectRatio: CGFloat {
        guard originalHeight > 0 else { return 1.0 }
        return originalWidth / originalHeight
    }
    
    init(assetId: String, width: CGFloat, height: CGFloat) {
        self.id = UUID().uuidString
        self.assetId = assetId
        self.originalWidth = width
        self.originalHeight = height
    }
}
