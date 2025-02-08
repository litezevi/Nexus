//
//  TaskViewFactory.swift
//  NexusApp
//

import SwiftUI

struct TaskViewFactory {
    
    static func makeView(for task: DeepseekTask) -> AnyView {
        switch task.taskType {
        case .translation:
            return AnyView(
                TranslationTaskView(phrase: task.text ?? "Нет текста")
            )
        case .sentenceBuilding:
            return AnyView(
                SentenceBuildingView(phrase: task.text ?? "Пусто")
            )
        case .multipleChoice:
            return AnyView(
                MultipleChoiceView(question: task.text ?? "???")
            )
        case .matchingPairs:
            return AnyView(
                MatchingPairsView(pairs: task.pairs ?? [])
            )
        }
    }
}
