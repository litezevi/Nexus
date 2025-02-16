import Foundation

class DeepseekAPIService {
    private let apiKey = "sk-4c88de14212c478abb0b641e280c4d6d"
    private let baseURL = "https://api.deepseek.com"
    
    func fetchLessonTasks(completion: @escaping ([DeepseekTask]?) -> Void) {
        let url = URL(string: "\(baseURL)/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let prompt = """
        Generate 8 English learning tasks in JSON format. Include a mix of:
        1. Multiple choice tasks (English to Russian translation)
        2. English sentence building tasks
        3. English-Russian word matching pairs
        
        Requirements:
        - Tasks must be suitable for beginners
        - Use common everyday phrases and vocabulary
        - All Russian translations must be accurate
        - Sentences must be grammatically correct
        - Include only valid JSON in response
        
        Follow this exact format:
        {
          "tasks": [
            {
              "type": "multipleChoice",
              "text": "English sentence",
              "question": "Select the correct translation for:\\n'English sentence'",
              "options": [
                "Correct Russian translation",
                "Wrong Russian option 1",
                "Wrong Russian option 2",
                "Wrong Russian option 3"
              ],
              "answer": "Correct Russian translation"
            },
            {
              "type": "sentenceBuilding",
              "text": "Make a sentence",
              "words": ["array", "of", "english", "words"],
              "answer": "correct english sentence"
            },
            {
              "type": "matchingPairs",
              "pairs": [
                ["english word", "russian translation"],
                ["another english", "another russian"]
              ]
            }
          ]
        }
        """
        
        let parameters: [String: Any] = [
            "messages": [
                [
                    "role": "system",
                    "content": "You are a specialized AI that generates English learning tasks. You only respond with valid JSON matching the specified format."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "model": "deepseek-chat",
            "max_tokens": 2000,
            "temperature": 0.7,
            "response_format": ["type": "json_object"]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error creating request body: \(error)")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API request error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                completion(nil)
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP Error: \(httpResponse.statusCode)")
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("Error Response: \(errorResponse)")
                }
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                // First decode the Deepseek response structure
                let deepseekResponse = try JSONDecoder().decode(DeepseekResponse.self, from: data)
                
                // Extract the JSON content from the response
                guard let jsonData = deepseekResponse.choices.first?.message.content.data(using: .utf8) else {
                    print("Error extracting JSON content from response")
                    completion(nil)
                    return
                }
                
                // Then decode the tasks
                let tasksResponse = try JSONDecoder().decode(AITasksResponse.self, from: jsonData)
                let tasks = tasksResponse.tasks.map { $0.toDeepseekTask() }
                
                DispatchQueue.main.async {
                    completion(tasks)
                }
            } catch {
                print("Error parsing API response: \(error)")
                if let responseStr = String(data: data, encoding: .utf8) {
                    print("Raw response: \(responseStr)")
                }
                completion(nil)
            }
        }
        
        task.resume()
    }
}

// Structure to parse Deepseek API response
struct DeepseekResponse: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: Message
    }
    
    struct Message: Decodable {
        let content: String
    }
}
