//
//  MultipleChoiceView.swift
//  NexusApp
//

import SwiftUI

struct MultipleChoiceView: View {
    let question: String
    
    // Пример статичных вариантов
    var variants: [String] = ["Вариант 1", "Вариант 2", "Вариант 3", "Вариант 4"]
    
    var body: some View {
        VStack(spacing: 16) {
            Text(question)
                .font(.headline)
            ForEach(variants, id: \.self) { variant in
                Button(variant) {
                    // Проверка ответа
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
        }
    }
}
