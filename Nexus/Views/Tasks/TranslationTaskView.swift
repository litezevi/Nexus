//
//  TranslationTaskView.swift
//  NexusApp
//

import SwiftUI

struct TranslationTaskView: View {
    let phrase: String
    let correctAnswer: String
    let onAnswerSubmitted: (Bool) -> Void
    
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
                checkAnswer()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
    
    private func checkAnswer() {
        // Нормализуем ответы для сравнения (убираем пробелы по краям, приводим к нижнему регистру)
        let normalizedUserAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedCorrectAnswer = correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Считаем ответ правильным, если совпадает с правильным ответом
        let isCorrect = normalizedUserAnswer == normalizedCorrectAnswer
        
        onAnswerSubmitted(isCorrect)
        
        // Очищаем поле ввода если ответ неверный
        if !isCorrect {
            userAnswer = ""
        }
    }
}
