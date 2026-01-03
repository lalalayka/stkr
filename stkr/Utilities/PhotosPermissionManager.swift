//
//  PhotosPermissionManager.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import Photos
import SwiftUI
import Combine

/// Manages Photos library permissions
class PhotosPermissionManager: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isCheckingPermission = true
    
    init() {
        checkInitialStatus()
    }
    
    private func checkInitialStatus() {
        // Add slight delay to show loading screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            self?.isCheckingPermission = false
        }
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                let granted = status == .authorized || status == .limited
                completion(granted)
            }
        }
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .authorized || authorizationStatus == .limited
    }
    
    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }
}
