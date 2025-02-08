//
//  LessonView.swift
//  NexusApp
//
//  Экран, где мы просим ИИ сгенерировать задания в формате JSON и парсим их.
//

import SwiftUI

struct LessonView: View {
    
    // Массив заданий, которые парсим из JSON
    @State private var tasks: [DeepseekTask] = []
    @State private var currentTaskIndex: Int = 0
    
    // Состояние загрузки/ошибки
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    // Ответ от ИИ (для отладки)
    @State private var aiResponse: String = ""
    
    // Ваш реальный ключ
    let deepseekApiKey = "sk-1e5122c55d46401e8242ccd005a5d6da"
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ProgressView("Генерирую задания...")
            }
            else if let error = errorMessage {
                Text("Ошибка: \(error)")
                    .foregroundColor(.red)
                    .padding()
            }
            else if tasks.isEmpty {
                VStack(spacing: 20) {
                    Text("Нет заданий (tasks.isEmpty)")
                        .font(.headline)
                    
                    // Покажем сырую строку (для диагностики)
                    ScrollView {
                        Text(aiResponse)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(height: 200)
                    
                    Button("Сгенерировать заново") {
                        generateTasksFromAI()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            else {
                // Есть массив tasks
                VStack(spacing: 16) {
                    
                    Text("Прогресс: \(currentTaskIndex + 1)/\(tasks.count)")
                    
                    // Текущее задание
                    if currentTaskIndex < tasks.count {
                        let currentTask = tasks[currentTaskIndex]
                        
                        // Фабрика выдаёт нужное View по типу задания
                        TaskViewFactory.makeView(for: currentTask)
                            .padding()
                        
                        Button(action: {
                            currentTaskIndex += 1
                        }) {
                            Text(currentTaskIndex == tasks.count - 1 ? "Завершить" : "Дальше")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    } else {
                        Text("Урок завершён!")
                            .font(.title)
                        
                        Button("Пройти заново") {
                            currentTaskIndex = 0
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
            }
        }
        .navigationBarTitle("Занятие", displayMode: .inline)
        .onAppear {
            generateTasksFromAI()
        }
    }
    
    /// Запрашиваем у ИИ сгенерировать JSON с заданиями
    private func generateTasksFromAI() {
        isLoading = true
        errorMessage = nil
        tasks = []
        currentTaskIndex = 0
        
        // Промпт для ИИ: просим вернуть только JSON
        let userPrompt = """
        Сгенерируй 4 случайных задания по английскому языку.\
        Формат ответа: {"tasks":[{"type":"...","text":"..."}, ... ]}
        Не добавляй никаких пояснений и текста вне JSON.\
        Каждое задание может быть типа: translation, matchingPairs, sentenceBuilding, multipleChoice.\
        Если matchingPairs — добавь "pairs":[["Cat","Кошка"],["Dog","Собака"]]\
        Если translation — добавь "text":"Hello" \
        Пример: {"tasks":[ ... ]}
        """
        
        let messages = [
            // Роль system: даём жёсткую инструкцию, чтобы ИИ возвращал только JSON
            DeepseekChatMessage(role: "system", content: "You ONLY output valid JSON. No code fences, no extra text."),
            // Роль user: сама задача
            DeepseekChatMessage(role: "user", content: userPrompt)
        ]
        
        DeepseekAPIService.fetchChatCompletion(
            apiKey: deepseekApiKey,
            messages: messages
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let rawText):
                    // Сохраним ответ для отладки
                    self.aiResponse = rawText
                    // Парсим
                    self.parseAIResponse(asJSON: rawText)
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    /// Очищаем ответ от потенциальных ```, \n и прочих символов,
    /// затем пытаемся декодировать как AITasksResponse.
    private func parseAIResponse(asJSON: String) {
        // 1. Удаляем возможные блоки кода ```...```
        var cleaned = asJSON
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // (При необходимости удаляем "Here's your JSON:" и т.д.)
        // cleaned = cleaned.replacingOccurrences(of: "Here is your JSON:", with: "")
        
        // 2. Превращаем в Data
        guard let data = cleaned.data(using: .utf8) else {
            self.errorMessage = "Не удалось сконвертировать ответ в UTF-8"
            return
        }
        
        // 3. Парсим
        do {
            let decoded = try JSONDecoder().decode(AITasksResponse.self, from: data)
            let dtos = decoded.tasks
            let mapped = dtos.map { $0.toDeepseekTask() }
            self.tasks = mapped
        } catch {
            self.errorMessage = "Ошибка парсинга JSON: \(error.localizedDescription)"
        }
    }
}
