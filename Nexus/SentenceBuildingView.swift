//
//  SentenceBuildingView.swift
//  NexusApp
//

import SwiftUI

struct SentenceBuildingView: View {
    // Пример набора слов
    let words: [String] = ["Я", "хочу", "учить", "SwiftUI"]
    
    var body: some View {
        VStack {
            Text("Составьте предложение:")
                .font(.headline)
            
            // Простейший пример: выводим слова
            // В реальном MVP можно добавлять перетаскивание (Drag and Drop) или кнопки
            ForEach(words, id: \.self) { word in
                Text(word)
                    .padding()
            }
        }
        .padding()
    }
}
