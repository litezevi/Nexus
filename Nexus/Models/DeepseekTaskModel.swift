//
//  DeepseekTaskModel.swift
//  NexusApp
//
//  Содержит структуры, нужные для хранения и парсинга заданий от ИИ.
//

import Foundation

// MARK: - Локальная модель, которую используем при отображении
struct DeepseekTask {
    let taskType: TaskType
    let text: String?
    let pairs: [(String, String)]?
    let words: [String]?
    let options: [String]?
    let question: String?
    let answer: String?
}

// MARK: - DTO для парсинга JSON от ИИ
struct AITasksResponse: Decodable {
    let tasks: [AITaskDTO]
}

/// Каждое задание в JSON-массиве
struct AITaskDTO: Decodable {
    let type: String
    let text: String?
    let pairs: [[String]]?
    let words: [String]?
    let options: [String]?
    let question: String?
    let answer: String?
    
    var validatedAnswer: String {
        switch type.lowercased() {
        case "matchingpairs":
            return "" // Для matchingPairs ответ не нужен
        default:
            return answer ?? ""
        }
    }
}

// MARK: - Преобразование AITaskDTO -> DeepseekTask
extension AITaskDTO {
    func toDeepseekTask() -> DeepseekTask {
        let mappedType: TaskType
        switch self.type.lowercased() {
        case "translation":
            mappedType = .translation
        case "sentencebuilding":
            mappedType = .sentenceBuilding
        case "multiplechoice":
            mappedType = .multipleChoice
        case "matchingpairs":
            mappedType = .matchingPairs
        default:
            mappedType = .translation  // fallback
        }
        
        // pairs: [[String]]? -> [(String, String)]?
        let mappedPairs: [(String, String)]? = self.pairs?.compactMap {
            guard $0.count == 2 else { return nil }
            return ($0[0], $0[1])
        }
        
        return DeepseekTask(
            taskType: mappedType,
            text: self.text,
            pairs: mappedPairs,
            words: self.words,
            options: self.options,
            question: self.question,
            answer: self.validatedAnswer
        )
    }
}
