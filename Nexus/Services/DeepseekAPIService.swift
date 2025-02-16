//
//  DeepseekAPIService.swift
//  NexusApp
//
//  Отвечает за взаимодействие с DeepSeek API для генерации текстов.
//

import Foundation

/// Пример задания для формата JSON
private let EXAMPLE_TASK = """
{
  "tasks": [
    {
      "type": "multipleChoice",
      "question": "Выберите правильный перевод:",
      "text": "The sun is shining today.",
      "options": [
        "Сегодня светит солнце.",
        "Сегодня идет дождь.",
        "Сегодня облачно.",
        "Сегодня жарко."
      ],
      "answer": "Сегодня светит солнце."
    },
    {
      "type": "matchingPairs",
      "pairs": [
        ["apple", "яблоко"],
        ["book", "книга"],
        ["cat", "кошка"],
        ["dog", "собака"]
      ]
    },
    {
      "type": "sentenceBuilding",
      "words": ["The", "cat", "sleeps", "on", "the", "bed"],
      "answer": "The cat sleeps on the bed"
    },
    {
      "type": "multipleChoice",
      "question": "Выберите правильный перевод:",
      "text": "She is reading a book.",
      "options": [
        "Она читает книгу.",
        "Она пишет письмо.",
        "Она смотрит телевизор.",
        "Она слушает музыку."
      ],
      "answer": "Она читает книгу."
    }
  ]
}
"""

class DeepseekAPIService {
    
    /// Запрашивает задания у DeepSeek API
    func fetchLessonTasks(completion: @escaping ([DeepseekTask]?) -> Void) {
        let systemPrompt = """
        Ты — AI, создающий задания по английскому языку для приложения.
        Твоя задача — создать 4 разных типа заданий без ручного ввода текста.

        Требования к заданиям:
        1. Только выбор из вариантов (Multiple Choice, Matching Pairs, Sentence Building).
        2. Никакого ручного ввода текста!
        3. Варианты ответов должны быть логичными и запутывающими.
        4. В заданиях с множественным выбором обязательно используй "question" с текстом "Выберите правильный перевод:".
        5. В Sentence Building используй короткие слова, которые легко разместятся на экране.
        6. Все задания должны следовать точному формату из примера.

        Пример формата JSON:\n\n\(EXAMPLE_TASK)
        """
        
        let messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": "Создай новый набор из 4 заданий точно в таком же формате."]
        ]
        
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": messages,
            "stream": false
        ]
        
        guard let url = URL(string: "https://api.deepseek.com/v1/chat/completions") else {
            print("Error: Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer sk-4c88de14212c478abb0b641e280c4d6d", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-11-01", forHTTPHeaderField: "Deepseek-Version")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            print("Sending request to:", url)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network error:", error)
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    completion(nil)
                    return
                }
                
                self.handleAPIResponse(data: data, completion: completion)
                
            }.resume()
            
        } catch {
            print("Request creation error:", error)
            completion(nil)
        }
    }
    
    /// Обрабатывает ответ от API
    private func handleAPIResponse(data: Data, completion: @escaping ([DeepseekTask]?) -> Void) {
        do {
            // Парсим основной ответ API
            if let apiResponse = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("API Response:", apiResponse)
            }
            
            // Декодируем ответ API
            struct APIResponse: Codable {
                struct Choice: Codable {
                    struct Message: Codable {
                        let content: String
                    }
                    let message: Message
                }
                let choices: [Choice]
            }
            
            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            
            guard let jsonString = response.choices.first?.message.content else {
                print("No content in API response")
                completion(nil)
                return
            }
            
            // Очищаем JSON от маркеров кода
            let cleanJson = jsonString
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("Clean JSON:", cleanJson)
            
            guard let taskData = cleanJson.data(using: .utf8) else {
                print("Failed to convert JSON string to data")
                completion(nil)
                return
            }
            
            // Декодируем задания
            let tasksResponse = try JSONDecoder().decode(AITasksResponse.self, from: taskData)
            let tasks = tasksResponse.tasks
            
            print("Successfully decoded \(tasks.count) tasks:")
            tasks.forEach { task in
                print("- Type: \(task.type)")
                if let text = task.text { print("  Text: \(text)") }
                if let pairs = task.pairs { print("  Pairs: \(pairs)") }
                if let words = task.words { print("  Words: \(words)") }
                if let question = task.question { print("  Question: \(question)") }
                if let options = task.options { print("  Options: \(options)") }
                if let answer = task.answer { print("  Answer: \(answer)") }
            }
            
            // Преобразуем в DeepseekTask
            let deepseekTasks = tasks.map { $0.toDeepseekTask() }
            
            // Проверяем все задания
            guard !deepseekTasks.isEmpty else {
                print("No tasks created")
                completion(nil)
                return
            }
            
            guard deepseekTasks.count == 4 else {
                print("Wrong number of tasks: \(deepseekTasks.count)")
                completion(nil)
                return
            }
            
            completion(deepseekTasks)
            
        } catch {
            print("Error processing API response:", error)
            if let errorData = String(data: data, encoding: .utf8) {
                print("Raw response:", errorData)
            }
            completion(nil)
        }
    }
}
