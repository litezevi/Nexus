//
//  DeepseekAPIService.swift
//  NexusApp
//
//  Отвечает за общение с DeepSeek (Chat Completion).
//

import Foundation

// MARK: - Структуры для запроса/ответа

/// Сообщение для Chat Completion
struct DeepseekChatMessage: Encodable {
    let role: String    // "system" | "user" | "assistant"
    let content: String
}

/// Тело запроса POST /chat/completions
struct DeepseekChatRequest: Encodable {
    let model: String
    let messages: [DeepseekChatMessage]
    let stream: Bool?
}

/// Ответ от DeepSeek (аналог OpenAI)
struct DeepseekCompletionResponse: Decodable {
    let choices: [DeepseekChoice]
}

struct DeepseekChoice: Decodable {
    let message: DeepseekMessage
}

struct DeepseekMessage: Decodable {
    let role: String
    let content: String
}

// MARK: - DeepseekAPIService

class DeepseekAPIService {
    
    /// Запрашиваем Chat Completion у DeepSeek
    ///
    /// - Parameters:
    ///   - apiKey: Ваш API-ключ (Bearer ...)
    ///   - baseURL: при необходимости (по умолчанию https://api.deepseek.com)
    ///   - model: название модели ("deepseek-chat")
    ///   - messages: массив (role + content)
    ///   - completion: вернёт результат либо .success(строка-ответ), либо .failure(ошибка)
    static func fetchChatCompletion(
        apiKey: String,
        baseURL: String = "https://api.deepseek.com",
        model: String = "deepseek-chat",
        messages: [DeepseekChatMessage],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Формируем URL: https://api.deepseek.com/chat/completions
        guard let url = URL(string: baseURL + "/v3/chat/completions") else {
            let urlError = NSError(domain: "DeepSeekAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid base URL"])
            completion(.failure(urlError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Заголовки
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Тело запроса
        let requestBody = DeepseekChatRequest(
            model: model,
            messages: messages,
            stream: false
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        // Выполняем запрос
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Смотрим на ошибку сети
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let noDataError = NSError(domain: "DeepSeekAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])
                completion(.failure(noDataError))
                return
            }
            
            // Парсим JSON-ответ
            do {
                let decoded = try JSONDecoder().decode(DeepseekCompletionResponse.self, from: data)
                
                // Берём контент первого choice
                if let firstChoice = decoded.choices.first {
                    completion(.success(firstChoice.message.content))
                } else {
                    let emptyError = NSError(domain: "DeepSeekAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Empty choices"])
                    completion(.failure(emptyError))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
