//
//  MultipleChoiceView.swift
//  NexusApp
//

import SwiftUI

struct MultipleChoiceView: View {
    // Пример вариантов
    let variants: [String] = [
        "Вариант 1",
        "Вариант 2",
        "Вариант 3",
        "Вариант 4"
    ]
    
    var body: some View {
        VStack {
            Text("Выберите правильный перевод:")
                .font(.headline)
            
            ForEach(variants, id: \.self) { variant in
                Button(action: {
                    // Логика выбора варианта
                }) {
                    Text(variant)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}
