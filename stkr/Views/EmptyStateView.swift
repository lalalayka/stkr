//
//  EmptyStateView.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import SwiftUI

/// Empty state view shown when no images are selected
struct EmptyStateView: View {
    let onSelectImages: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 8) {
                
                Image(systemName: "photo.stack")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                
                Text("Let’s stack\nsome memories")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    
            }
            
            Spacer()
            
            Button(action: onSelectImages) {
                Text("Select Images")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .buttonBorderShape(.roundedRectangle)
            .buttonSizing(.flexible)
            .tint(.primary)
            .foregroundStyle(.background)
            .padding(.horizontal)
            .accessibilityLabel("Open photo library")
//            .padding(24)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    EmptyStateView(onSelectImages: { print("Select images") })
}
