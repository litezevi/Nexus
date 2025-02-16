import SwiftUI

struct SentenceBuildingView: View {
    let words: [String]
    let correctAnswer: String
    let onAnswerSubmitted: (Bool) -> Void
    
    @State private var arrangedWords: [String]
    @State private var showFeedback = false
    
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
            
            Text(arrangedWords.joined(separator: " "))
                .font(.title3)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 8)
            ], spacing: 12) {
                ForEach(arrangedWords.indices, id: \.self) { index in
                    Text(arrangedWords[index])
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
                        .onDrag {
                            NSItemProvider(object: String(index) as NSString)
                        }
                        .onDrop(of: [.text], delegate: WordDropDelegate(
                            items: $arrangedWords,
                            currentIndex: index
                        ))
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
