//
//  WelcomeView.swift
//  stkr
//
//  Created by sergey.kovalchuk on 03/01/2026.
//

import SwiftUI

/// Welcome screen shown on app launch
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("splashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    WelcomeView()
}
