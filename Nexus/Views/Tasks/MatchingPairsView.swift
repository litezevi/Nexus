//
//  MatchingPairsView.swift
//  NexusApp
//

import SwiftUI

struct MatchingPairsView: View {
    let pairs: [(String, String)]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Сопоставьте пары:")
            ForEach(pairs, id: \.0) { pair in
                HStack {
                    Text(pair.0)
                    Text("—")
                    Text(pair.1)
                }
            }
        }
    }
}
