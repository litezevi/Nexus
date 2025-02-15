//
//  DeepseekAPIService.swift
//  NexusApp
//
//  Отвечает за взаимодействие с DeepSeek API для генерации текстов.
//

import Foundation

// MARK: - Структуры для запроса/ответа

/// Сообщение для Chat Completion
struct DeepseekChatMessage: Codable {
    let role: String    // "system" | "user" | "assistant"
    let content: String
}

/// Тело запроса POST /chat/completions
struct DeepseekChatRequest: Codable {
    let model: String
    let messages: [DeepseekChatMessage]
    let stream: Bool?
}

/// Ответ от DeepSeek API
struct DeepseekCompletionResponse: Codable {
    let choices: [DeepseekChoice]
}

struct DeepseekChoice: Codable {
    let message: DeepseekMessage
}

struct DeepseekMessage: Codable {
    let role: String
    let content: String
}

// MARK: - DeepseekAPIService

class DeepseekAPIService {
    
    /// Запрашивает Chat Completion у DeepSeek API
    ///
    /// - Parameters:
    ///   - apiKey: API-ключ DeepSeek (формат "Bearer sk-...")
    ///   - baseURL: URL API (по умолчанию "https://api.deepseek.com")
    ///   - model: Название модели (по умолчанию "deepseek-chat")
    ///   - messages: Массив сообщений в чате
    ///   - completion: Возвращает результат: либо .success(ответ-строка), либо .failure(ошибка)
    static func fetchChatCompletion(
        apiKey: String = "sk-4c88de14212c478abb0b641e280c4d6d",
        baseURL: String = "https://api.deepseek.com",
        model: String = "deepseek-chat",
        messages: [DeepseekChatMessage],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/v3/chat/completions") else {
            let urlError = NSError(domain: "DeepSeekAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Неверный baseURL"])
            completion(.failure(urlError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Устанавливаем заголовки
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Формируем тело запроса
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
        
        // Отправляем запрос
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем наличие данных
            guard let data = data, !data.isEmpty else {
                let noDataError = NSError(domain: "DeepSeekAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Пустой ответ от сервера"])
                completion(.failure(noDataError))
                return
            }
            
            // Логирование данных (удалить в продакшне)
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Ответ DeepSeek API:", rawResponse)
            }
            
            // Парсим JSON-ответ
            do {
                let decodedResponse = try JSONDecoder().decode(DeepseekCompletionResponse.self, from: data)
                
                guard let firstChoice = decodedResponse.choices.first else {
                    let emptyError = NSError(domain: "DeepSeekAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ответ не содержит данных"])
                    completion(.failure(emptyError))
                    return
                }
                
                completion(.success(firstChoice.message.content))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
