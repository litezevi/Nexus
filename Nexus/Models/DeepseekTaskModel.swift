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
}

// MARK: - DTO для парсинга JSON от ИИ

/// Пример: ИИ должен вернуть JSON вида:
/// {
///   "tasks": [
///     {
///       "type": "translation",
///       "text": "Hello!"
///     },
///     {
///       "type": "matchingPairs",
///       "pairs": [["Cat", "Кошка"], ["Dog", "Собака"]]
///     }
///   ]
/// }
///
struct AITasksResponse: Decodable {
    let tasks: [AITaskDTO]
}

/// Каждое задание в JSON-массиве
struct AITaskDTO: Decodable {
    let type: String       // "translation", "matchingPairs", etc.
    let text: String?
    let pairs: [[String]]?
    // При необходимости: let variants: [String]? // для multipleChoice
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
            pairs: mappedPairs
        )
    }
}
