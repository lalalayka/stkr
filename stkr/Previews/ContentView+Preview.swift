//
//  ContentView+Preview.swift
//  stkr
//
//  Created by sergey.kovalchuk on 02/01/2026.
//

import SwiftUI

#Preview("Empty State") {
    ContentView()
}

#Preview("With Images") {
    let viewModel = CompositionViewModel()
    
    // Add mock images
    viewModel.addImage(assetId: "mock-1", width: 1080, height: 1920)
    viewModel.addImage(assetId: "mock-2", width: 1920, height: 1080)
    viewModel.addImage(assetId: "mock-3", width: 1080, height: 1080)
    
    return ContentView()
}
