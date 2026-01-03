//
//  ImageListView.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import SwiftUI
import Combine

private struct TileFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

/// Canvas: Reorderable list of selected images with drag-and-drop support
struct Canvas: View {
    @ObservedObject var viewModel: CompositionViewModel
    @State private var showPhotoPicker = false
    @State private var replaceAtIndex: Int?
    @State private var activeTileId: String?
    @State private var tileFrames: [String: CGRect] = [:]
    @State private var draggingId: String?
    @State private var lastReorderTargetId: String?
    
    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / CompositionViewModel.canvasWidth
            let scaledSpacing = CompositionViewModel.gapBetweenImages * scale
            
            VStack(spacing: scaledSpacing) {
                ForEach(Array(viewModel.state.images.enumerated()), id: \.element.id) { index, imageSelection in
                    ZStack {
                        ImageTile(
                            imageSelection: imageSelection,
                            index: index,
                            activeTileId: $activeTileId,
                            onReplace: {
                                replaceAtIndex = index
                                showPhotoPicker = true
                            },
                            onRemove: {
                                viewModel.removeImage(at: index)
                            }
                        )
                        
                        // Invisible draggable overlay on the right side (where grabber is)
                        HStack {
                            Spacer()
                            Color.clear
                                .frame(width: 76, height: 76)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Close overlay without stealing the drag session.
                                    activeTileId = nil
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .named("canvas"))
                                        .onChanged { value in
                                            if draggingId == nil {
                                                draggingId = imageSelection.id
                                            }
                                            activeTileId = nil
                                            handleReorder(location: value.location, draggedId: imageSelection.id)
                                        }
                                        .onEnded { _ in
                                            draggingId = nil
                                            lastReorderTargetId = nil
                                        }
                                )
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: TileFramePreferenceKey.self,
                                    value: [imageSelection.id: proxy.frame(in: .named("canvas"))]
                                )
                        }
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width * (16.0 / 9.0))
            .background(Color.black)
            .coordinateSpace(name: "canvas")
            .onPreferenceChange(TileFramePreferenceKey.self) { frames in
                tileFrames = frames
            }
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
    
    private func handleReorder(location: CGPoint, draggedId: String) {
        guard let sourceIndex = viewModel.state.images.firstIndex(where: { $0.id == draggedId }) else {
            return
        }
        guard let targetId = tileFrames.first(where: { $0.value.contains(location) })?.key else {
            return
        }
        if targetId == lastReorderTargetId {
            return
        }
        lastReorderTargetId = targetId
        guard let targetIndex = viewModel.state.images.firstIndex(where: { $0.id == targetId }),
              targetIndex != sourceIndex else {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.15)) {
            viewModel.moveImage(from: sourceIndex, to: targetIndex)
        }
    }
}

#Preview {
    let viewModel = CompositionViewModel()
    Canvas(viewModel: viewModel)
}
