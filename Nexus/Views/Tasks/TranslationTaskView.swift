//
//  TranslationTaskView.swift
//  NexusApp
//

import SwiftUI

struct TranslationTaskView: View {
    let phrase: String
    @State private var userAnswer: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Переведите фразу:")
            Text(phrase)
                .font(.title3)
                .padding()
            
            TextField("Введите перевод", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Проверить") {
                // Логика проверки
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}
