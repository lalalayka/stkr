//
//  PhotoPickerCoordinator.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import PhotosUI
import SwiftUI

/// Coordinator to handle PHPickerViewController integration
struct PhotoPickerCoordinator: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CompositionViewModel
    var maxSelections: Int = 4
    var allowReplace: Bool = false
    var replaceIndex: Int?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = allowReplace ? 1 : (maxSelections - viewModel.state.images.count)
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, allowReplace: allowReplace, replaceIndex: replaceIndex)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let viewModel: CompositionViewModel
        var allowReplace: Bool
        var replaceIndex: Int?
        
        init(viewModel: CompositionViewModel, allowReplace: Bool, replaceIndex: Int?) {
            self.viewModel = viewModel
            self.allowReplace = allowReplace
            self.replaceIndex = replaceIndex
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            print("📸 Picker finished with \(results.count) results")
            
            Task { @MainActor in
                for result in results {
                    _ = result.itemProvider
                    
                    // Get asset identifier for later loading
                    if let assetIdentifier = result.assetIdentifier {
                        print("📸 Processing asset: \(assetIdentifier)")
                        // Fetch the PHAsset to get dimensions
                        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject {
                            let width = CGFloat(asset.pixelWidth)
                            let height = CGFloat(asset.pixelHeight)
                            
                            print("📸 Asset dimensions: \(width)x\(height)")
                            
                            if let replaceIndex = replaceIndex, allowReplace {
                                viewModel.replaceImage(at: replaceIndex, assetId: assetIdentifier, width: width, height: height)
                                print("📸 Replaced image at index \(replaceIndex)")
                            } else {
                                viewModel.addImage(assetId: assetIdentifier, width: width, height: height)
                                print("📸 Added image, total count: \(viewModel.state.images.count)")
                            }
                        } else {
                            print("⚠️ Failed to fetch asset")
                        }
                    } else {
                        print("⚠️ No asset identifier found")
                    }
                }
            }
        }
    }
}
