//
//  TaskViewFactory.swift
//  Nexus
//
//  Created by Litezevin on 9/2/25.
//
//
//  TaskViewFactory.swift
//  NexusApp
//

import SwiftUI

struct TaskViewFactory {
    static func makeView(for type: TaskType) -> AnyView {
        switch type {
        case .translation:
            return AnyView(TranslationTaskView())
        case .sentenceBuilding:
            return AnyView(SentenceBuildingView())
        case .multipleChoice:
            return AnyView(MultipleChoiceView())
        case .matchingPairs:
            return AnyView(MatchingPairsView())
        }
    }
}
