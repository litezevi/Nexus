//
//  MatchingPairsView.swift
//  NexusApp
//

import SwiftUI

struct MatchingPairsView: View {
    // Пример пар
    let pairs: [(String, String)] = [
        ("Cat", "Кот"),
        ("Dog", "Собака"),
        ("Apple", "Яблоко")
    ]
    
    var body: some View {
        VStack {
            Text("Сопоставьте слова с переводом:")
                .font(.headline)
            
            ForEach(pairs, id: \.0) { pair in
                HStack {
                    Text(pair.0)
                    Spacer()
                    Text("—")
                    Spacer()
                    Text(pair.1)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .padding()
    }
}
