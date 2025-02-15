//
//  MultipleChoiceView.swift
//  NexusApp
//

import SwiftUI

struct MultipleChoiceView: View {
    let question: String
    let options: [String]
    let correctAnswer: String
    let onAnswerSubmitted: (Bool) -> Void
    
    @State private var selectedOption: String?
    @State private var showFeedback = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text(question)
                .font(.headline)
                .padding()
                .multilineTextAlignment(.center)
            
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selectOption(option)
                }) {
                    Text(option)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(backgroundColor(for: option))
                        .foregroundColor(foregroundColor(for: option))
                        .cornerRadius(8)
                }
                .disabled(showFeedback)
            }
            
            if !showFeedback {
                Button("Проверить") {
                    checkAnswer()
                }
                .padding()
                .background(selectedOption == nil ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(selectedOption == nil)
            }
        }
        .padding()
    }
    
    private func selectOption(_ option: String) {
        selectedOption = option
    }
    
    private func checkAnswer() {
        guard let selected = selectedOption else { return }
        
        showFeedback = true
        let isCorrect = selected == correctAnswer
        
        // Анимируем отображение результата
        withAnimation {
            onAnswerSubmitted(isCorrect)
        }
    }
    
    private func backgroundColor(for option: String) -> Color {
        guard showFeedback, let selected = selectedOption else {
            return option == selectedOption ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2)
        }
        
        if option == correctAnswer {
            return Color.green.opacity(0.3)
        } else if option == selected && option != correctAnswer {
            return Color.red.opacity(0.3)
        }
        return Color.gray.opacity(0.2)
    }
    
    private func foregroundColor(for option: String) -> Color {
        if showFeedback && option == correctAnswer {
            return .green
        } else if showFeedback && option == selectedOption && option != correctAnswer {
            return .red
        }
        return option == selectedOption ? .blue : .primary
    }
}
