//
//  SentenceBuildingView.swift
//  NexusApp
//

import SwiftUI

struct SentenceBuildingView: View {
    let phrase: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Составьте предложение:")
            Text(phrase)
                .font(.title3)
            
            // ... логика
        }
    }
}
