//
//  TranslationTaskView.swift
//  NexusApp
//

import SwiftUI

struct TranslationTaskView: View {
    
    @State private var userAnswer: String = ""
    
    var body: some View {
        VStack {
            Text("Переведите фразу:")
                .font(.headline)
            
            // Пример условной исходной фразы
            Text("Hello, world!")
                .font(.title2)
                .padding()
            
            TextField("Введите перевод", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Кнопка "Проверить"
            Button(action: {
                // Логика проверки ответа
            }) {
                Text("Проверить")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}
