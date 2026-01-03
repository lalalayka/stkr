//
//  ImageListView.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

/// Canvas: Reorderable list of selected images with drag-and-drop support
struct Canvas: View {
    @ObservedObject var viewModel: CompositionViewModel
    @State private var showPhotoPicker = false
    @State private var replaceAtIndex: Int?
    @State private var activeTileId: String?
    @State private var dragEnabledForId: String?
    
    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / CompositionViewModel.canvasWidth
            let scaledSpacing = CompositionViewModel.gapBetweenImages * scale
            
            VStack(spacing: scaledSpacing) {
                ForEach(Array(viewModel.state.images.enumerated()), id: \.element.id) { index, imageSelection in
                    ImageTile(
                        imageSelection: imageSelection,
                        index: index,
                        activeTileId: $activeTileId,
                        isDragEnabled: dragEnabledForId == imageSelection.id,
                        onReplace: {
                            replaceAtIndex = index
                            showPhotoPicker = true
                        },
                        onRemove: {
                            viewModel.removeImage(at: index)
                        },
                        onLongPress: {
                            // Haptic feedback
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            dragEnabledForId = imageSelection.id
                        },
                        onDragEnd: {
                            dragEnabledForId = nil
                        }
                    )
                    .opacity(dragEnabledForId == imageSelection.id ? 0.5 : 1.0)
                    .onDrag {
                        NSItemProvider(object: imageSelection.id as NSString)
                    }
                    .onDrop(of: [.text], delegate: ImageDropDelegate(
                        destinationIndex: index,
                        viewModel: viewModel
                    ))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width * (16.0 / 9.0))
            .background(Color.black)
        }
        .sheet(isPresented: $showPhotoPicker) {
            if let replaceIndex = replaceAtIndex {
                PhotoPickerCoordinator(
                    viewModel: viewModel,
                    maxSelections: CompositionState.maxImages,
                    allowReplace: true,
                    replaceIndex: replaceIndex
                )
            } else {
                PhotoPickerCoordinator(
                    viewModel: viewModel,
                    maxSelections: CompositionState.maxImages
                )
            }
        }
        .onChange(of: showPhotoPicker) { oldValue, newValue in
            if !newValue {
                replaceAtIndex = nil
            }
        }
    }
}

// MARK: - Drop Delegate for reordering
struct ImageDropDelegate: DropDelegate {
    let destinationIndex: Int
    @ObservedObject var viewModel: CompositionViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [.text]).first else { return false }
        
        item.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
            guard let data = data as? Data,
                  let draggedId = String(data: data, encoding: .utf8) else { return }
            
            Task { @MainActor in
                guard let sourceIndex = viewModel.state.images.firstIndex(where: { $0.id == draggedId }),
                      sourceIndex != destinationIndex else { return }
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.moveImage(from: sourceIndex, to: destinationIndex)
                }
            }
        }
        return true
    }
}

#Preview {
    let viewModel = CompositionViewModel()
    Canvas(viewModel: viewModel)
}
