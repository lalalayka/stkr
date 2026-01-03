//
//  LoadingView.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import SwiftUI

/// Loading screen shown during initial app setup
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.primary)
            
            Text("Let's stack some memories")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    LoadingView()
}
