//
//  TaskViewFactory.swift
//  NexusApp
//

import SwiftUI

struct TaskViewFactory {
    
    static func view(for task: DeepseekTask, onAnswerSubmitted: @escaping (Bool) -> Void) -> AnyView {
        switch task.taskType {
        case .translation:
            guard let text = task.text,
                  let answer = task.answer else {
                return AnyView(errorView(message: "Missing translation data"))
            }
            return AnyView(
                TranslationTaskView(
                    phrase: text,
                    correctAnswer: answer,
                    onAnswerSubmitted: onAnswerSubmitted
                )
            )
            
        case .sentenceBuilding:
            guard let words = task.words,
                  let answer = task.answer else {
                return AnyView(errorView(message: "Missing sentence building data"))
            }
            return AnyView(
                SentenceBuildingView(
                    words: words,
                    correctAnswer: answer,
                    onAnswerSubmitted: onAnswerSubmitted
                )
            )
            
        case .multipleChoice:
            guard let question = task.question,
                  let options = task.options,
                  let answer = task.answer else {
                return AnyView(errorView(message: "Missing multiple choice data"))
            }
            return AnyView(
                MultipleChoiceView(
                    question: question,
                    options: options,
                    correctAnswer: answer,
                    onAnswerSubmitted: onAnswerSubmitted
                )
            )
            
        case .matchingPairs:
            guard let pairs = task.pairs else {
                return AnyView(errorView(message: "Missing pairs data"))
            }
            return AnyView(
                MatchingPairsView(
                    pairs: pairs,
                    onAnswerSubmitted: onAnswerSubmitted
                )
            )
        }
    }
    
    private static func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
