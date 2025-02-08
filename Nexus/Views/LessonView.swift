//
//  LessonView.swift
//  NexusApp
//
//  Экран, где мы просим ИИ сгенерировать задания в формате JSON и парсим их.
//

import SwiftUI

struct LessonView: View {
    
    @State private var tasks: [DeepseekTask] = []
    @State private var currentTaskIndex: Int = 0
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var aiResponse: String = ""
    
    let deepseekApiKey = "sk-1e5122c55d46401e8242ccd005a5d6da"
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                loadingView
            }
            else if let error = errorMessage {
                errorView(error: error)
            }
            else if tasks.isEmpty {
                emptyStateView
            }
            else {
                taskContentView
            }
        }
        .navigationBarTitle("Занятие", displayMode: .inline)
        .onAppear {
            generateTasksFromAI()
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView("Генерирую задания...")
                .font(.headline)
                .padding()
            
            LottieView(name: "loading", loopMode: .loop)
                .frame(width: 200, height: 200)
        }
    }
    
    private func errorView(error: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .padding()
            
            Text("Ошибка: \(error)")
                .font(.headline)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: generateTasksFromAI) {
                Text("Попробовать снова")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Text("Нет заданий")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Button(action: generateTasksFromAI) {
                Text("Сгенерировать задания")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            if !aiResponse.isEmpty {
                Text("Ответ ИИ:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ScrollView {
                    Text(aiResponse)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(height: 200)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding()
            }
        }
        .padding()
    }
    
    private var taskContentView: some View {
        VStack(spacing: 20) {
            progressView
            
            if currentTaskIndex < tasks.count {
                let currentTask = tasks[currentTaskIndex]
                
                TaskViewFactory.makeView(for: currentTask)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .transition(.slide)
                
                Spacer()
                
                HStack {
                    if currentTaskIndex > 0 {
                        Button(action: {
                            withAnimation {
                                currentTaskIndex -= 1
                            }
                        }) {
                            Text("Назад")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            if currentTaskIndex < tasks.count - 1 {
                                currentTaskIndex += 1
                            } else {
                                // Lesson completed
                            }
                        }
                    }) {
                        Text(currentTaskIndex == tasks.count - 1 ? "Завершить" : "Дальше")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .padding(.top, 20)
    }
    
    private var progressView: some View {
        HStack {
            Text("Прогресс: \(currentTaskIndex + 1)/\(tasks.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            ProgressView(value: Double(currentTaskIndex + 1), total: Double(tasks.count))
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 150)
        }
        .padding(.horizontal)
    }
    
    private func generateTasksFromAI() {
        isLoading = true
        errorMessage = nil
        tasks = []
        currentTaskIndex = 0
        
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
            DeepseekChatMessage(role: "system", content: "You ONLY output valid JSON. No code fences, no extra text."),
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
                    self.aiResponse = rawText
                    self.parseAIResponse(asJSON: rawText)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func parseAIResponse(asJSON: String) {
        var cleaned = asJSON
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleaned.data(using: .utf8) else {
            self.errorMessage = "Не удалось сконвертировать ответ в UTF-8"
            return
        }
        
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
