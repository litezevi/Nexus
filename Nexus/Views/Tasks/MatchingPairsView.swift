//
//  MatchingPairsView.swift
//  NexusApp
//

import SwiftUI

struct MatchingPairsView: View {
    let pairs: [(String, String)]
    let onAnswerSubmitted: (Bool) -> Void
    
    @State private var selectedLeftWord: String?
    @State private var selectedRightWord: String?
    @State private var matchedPairs: Set<String> = []
    @State private var shuffledRightWords: [String]
    
    init(pairs: [(String, String)], onAnswerSubmitted: @escaping (Bool) -> Void) {
        self.pairs = pairs
        self.onAnswerSubmitted = onAnswerSubmitted
        // Перемешиваем правую колонку слов
        self._shuffledRightWords = State(initialValue: pairs.map { $0.1 }.shuffled())
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Сопоставьте пары:")
                .font(.headline)
                .padding()
            
            HStack(spacing: 20) {
                // Левая колонка (английские слова)
                VStack(spacing: 12) {
                    ForEach(pairs, id: \.0) { pair in
                        WordButton(
                            word: pair.0,
                            isSelected: selectedLeftWord == pair.0,
                            isMatched: matchedPairs.contains(pair.0),
                            action: { selectLeftWord(pair.0) }
                        )
                    }
                }
                
                // Разделительная линия
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2)
                
                // Правая колонка (русские слова)
                VStack(spacing: 12) {
                    ForEach(shuffledRightWords, id: \.self) { word in
                        WordButton(
                            word: word,
                            isSelected: selectedRightWord == word,
                            isMatched: matchedPairs.contains(findLeftPair(for: word)),
                            action: { selectRightWord(word) }
                        )
                    }
                }
            }
            .padding()
            
            // Показываем кнопку "Завершить" только когда все пары сопоставлены
            if matchedPairs.count == pairs.count {
                Button("Завершить") {
                    checkAllPairs()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
    
    private func selectLeftWord(_ word: String) {
        // Пропускаем если слово уже сопоставлено
        guard !matchedPairs.contains(word) else { return }
        
        selectedLeftWord = word
        checkForMatch()
    }
    
    private func selectRightWord(_ word: String) {
        // Пропускаем если слово уже сопоставлено
        guard !matchedPairs.contains(findLeftPair(for: word)) else { return }
        
        selectedRightWord = word
        checkForMatch()
    }
    
    private func checkForMatch() {
        guard let leftWord = selectedLeftWord,
              let rightWord = selectedRightWord else { return }
        
        // Проверяем, является ли выбранная пара правильной
        if pairs.contains(where: { $0.0 == leftWord && $0.1 == rightWord }) {
            matchedPairs.insert(leftWord)
        }
        
        // Сбрасываем выбор
        selectedLeftWord = nil
        selectedRightWord = nil
    }
    
    private func findLeftPair(for rightWord: String) -> String {
        guard let pair = pairs.first(where: { $0.1 == rightWord }) else { return "" }
        return pair.0
    }
    
    private func checkAllPairs() {
        // Все пары должны быть правильно сопоставлены
        let isAllCorrect = matchedPairs.count == pairs.count
        onAnswerSubmitted(isAllCorrect)
    }
}

struct WordButton: View {
    let word: String
    let isSelected: Bool
    let isMatched: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(word)
                .frame(width: 120)
                .padding()
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(strokeColor, lineWidth: isSelected ? 2 : 0)
                )
        }
        .disabled(isMatched)
    }
    
    private var backgroundColor: Color {
        if isMatched {
            return .green.opacity(0.2)
        } else if isSelected {
            return .blue.opacity(0.2)
        } else {
            return .gray.opacity(0.1)
        }
    }
    
    private var foregroundColor: Color {
        if isMatched {
            return .green
        } else if isSelected {
            return .blue
        } else {
            return .primary
        }
    }
    
    private var strokeColor: Color {
        isSelected ? .blue : .clear
    }
}
