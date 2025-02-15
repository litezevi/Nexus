//
//  SentenceBuildingView.swift
//  NexusApp
//

import SwiftUI

struct SentenceBuildingView: View {
    let words: [String]
    let correctAnswer: String
    let onAnswerSubmitted: (Bool) -> Void
    
    @State private var arrangedWords: [String]
    @State private var showFeedback = false
    
    // Инициализируем массив слов в случайном порядке
    init(words: [String], correctAnswer: String, onAnswerSubmitted: @escaping (Bool) -> Void) {
        self.words = words
        self.correctAnswer = correctAnswer
        self.onAnswerSubmitted = onAnswerSubmitted
        self._arrangedWords = State(initialValue: words.shuffled())
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Составьте предложение:")
                .font(.headline)
                .padding()
            
            // Отображение составленного предложения
            Text(arrangedWords.joined(separator: " "))
                .font(.title3)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            // Область для перетаскивания слов
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100, maximum: 200))
            ], spacing: 10) {
                ForEach(arrangedWords.indices, id: \.self) { index in
                    WordCardView(word: arrangedWords[index])
                        .onDrag {
                            NSItemProvider(object: String(index) as NSString)
                        }
                        .onDrop(of: [.text], delegate: DropViewDelegate(item: arrangedWords[index],
                                                                      currentIndex: index,
                                                                      items: $arrangedWords))
                }
            }
            .padding()
            
            if !showFeedback {
                Button("Проверить") {
                    checkAnswer()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
    
    private func checkAnswer() {
        showFeedback = true
        let userAnswer = arrangedWords.joined(separator: " ")
        let isCorrect = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
                       correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        onAnswerSubmitted(isCorrect)
    }
}

// Вспомогательное view для отображения слова
struct WordCardView: View {
    let word: String
    
    var body: some View {
        Text(word)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
    }
}

// Делегат для обработки перетаскивания
struct DropViewDelegate: DropDelegate {
    let item: String
    let currentIndex: Int
    @Binding var items: [String]
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return false }
        
        itemProvider.loadObject(ofClass: NSString.self) { (string, error) in
            guard let nsString = string as? NSString,
                  let index = Int(nsString as String) else { return }
            
            DispatchQueue.main.async {
                let movingItem = items[index]
                items.remove(at: index)
                items.insert(movingItem, at: currentIndex)
            }
        }
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Можно добавить анимацию при наведении
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
