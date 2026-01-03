//
//  ExportStatusView.swift
//  stkr
//
//  Created by sergey.kovalchuk on 03/01/2026.
//

import SwiftUI
import UIKit

enum ExportStatus: Equatable {
    case exporting
    case success
    case failure(String)
}

/// Export status view shown during export process
struct ExportStatusView: View {
    let status: ExportStatus
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            // Content card
            VStack(spacing: 8) {
                switch status {
                case .exporting:
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.primary)
                    
                    Text("Exporting...")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .padding(8)
                    
                case .success:
                    Image(systemName: "checkmark.circle")
                        .font(.largeTitle)
                        .foregroundStyle(.primary)
                    
                    Text("Saved to Photos")
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                case .failure(let message):
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.primary)
                    
                    Text("Export Failed")
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(32)
        }
        .onChange(of: status) { oldValue, newValue in
            // Trigger haptic feedback
            switch newValue {
            case .exporting:
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            case .success:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            case .failure:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
            
            // Auto-dismiss when status changes to success or failure
            switch newValue {
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onDismiss()
                }
            case .failure:
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    onDismiss()
                }
            case .exporting:
                break
            }
        }
    }
}

#Preview("Exporting") {
    ExportStatusView(status: .exporting, onDismiss: {})
}

#Preview("Success") {
    ExportStatusView(status: .success, onDismiss: {})
}

#Preview("Failure") {
    ExportStatusView(status: .failure("Could not save\nto Photos library"), onDismiss: {})
}
