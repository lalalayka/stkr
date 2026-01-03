//
//  ContentView.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import SwiftUI
import Photos
import Combine

struct ContentView: View {
    @StateObject private var viewModel = CompositionViewModel()
    @StateObject private var permissionManager = PhotosPermissionManager()
    @State private var showPhotoPicker = false
    @State private var showPermissionAlert = false
    @State private var exportStatus: ExportStatus?
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack() {
                Color(.secondarySystemBackground)
                    .ignoresSafeArea()
                
                if isLoading {
                    // Welcome/Loading screen
                    WelcomeView()
                } else if permissionManager.isCheckingPermission {
                    // Loading state
                    LoadingView()
                } else if permissionManager.isDenied {
                    // Permission denied state
                    PermissionDeniedView()
                } else if viewModel.state.images.isEmpty {
                    // Empty state
                    EmptyStateView(
                        onSelectImages: {
                            if permissionManager.isAuthorized {
                                showPhotoPicker = true
                            } else {
                                permissionManager.requestPermission { granted in
                                    if granted {
                                        showPhotoPicker = true
                                    } else {
                                        showPermissionAlert = true
                                    }
                                }
                            }
                        }
                    )
                } else {
                    // Selection state with Canvas
                    VStack {
                        Spacer()
                        Canvas(viewModel: viewModel)
                        Spacer()
                    }
                }
                
                // Export status overlay (on top of everything)
                if let exportStatus = exportStatus {
                    ExportStatusView(status: exportStatus) {
                        self.exportStatus = nil
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1.3), value: self.exportStatus)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if !viewModel.state.images.isEmpty && viewModel.state.canAddMore {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                if permissionManager.isAuthorized {
                                    showPhotoPicker = true
                                } else {
                                    permissionManager.requestPermission { granted in
                                        if granted {
                                            showPhotoPicker = true
                                        } else {
                                            showPermissionAlert = true
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                            .disabled(exportStatus != nil)
                            .accessibilityLabel("Add more images")
                            .accessibilityHint("Opens photo picker to select additional images")
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if !viewModel.state.images.isEmpty {
                            Button {
                                viewModel.clearAll()
                            } label: {
                                Image(systemName: "trash")
//                                    .foregroundStyle(.red)
                            }
                            .disabled(exportStatus != nil)
                            .accessibilityLabel("Clear all images")
                            .accessibilityHint("Removes all selected images from composition")
                            
                            Button {
                                exportAndSaveToPhotos()
                            } label: {
                                Image(systemName: "square.and.arrow.down")
                            }
                            .disabled(exportStatus != nil)
                            .accessibilityLabel("Export to Photos")
                            .accessibilityHint("Saves the composed image to your Photos library")
                        }
                    }
                }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Dismiss welcome screen after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoading = false
                }
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerCoordinator(
                viewModel: viewModel,
                maxSelections: CompositionState.maxImages
            )
        }
        .alert("Photos Access Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please allow access to your photos to use this app.")
        }
    }
    
    private func exportAndSaveToPhotos() {
        exportStatus = .exporting
        
        ImageComposer.compose(imageSelections: viewModel.state.images) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let heicData):
                    // Save to Photos
                    if let image = UIImage(data: heicData) {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exportStatus = .success
                        }
                    } else {
                        exportStatus = .failure("Could not create image")
                    }
                    
                case .failure(let error):
                    exportStatus = .failure(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
