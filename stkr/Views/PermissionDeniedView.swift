//
//  PermissionDeniedView.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import SwiftUI

/// View shown when Photos permission is denied
struct PermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("🫠")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                
                Text("Welp, we can’t do anything\nwithout access to Photos")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }) {
                Text("Open settings")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .buttonBorderShape(.roundedRectangle)
            .buttonSizing(.flexible)
            .tint(.primary)
            .foregroundStyle(.background)
            .padding(.horizontal)
            .accessibilityLabel("Open app settings")

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    PermissionDeniedView()
}
