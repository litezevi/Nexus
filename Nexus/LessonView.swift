//
//  LessonView.swift
//  NexusApp
//

import SwiftUI

struct LessonView: View {
    
    // Список заданий (в реальном проекте — генерируется или приходит от Deepseek API)
    @State private var tasks: [TaskType] = [
        .translation,
        .sentenceBuilding,
        .multipleChoice,
        .matchingPairs
    ]
    
    // Индекс текущего задания
    @State private var currentTaskIndex: Int = 0
    
    var body: some View {
        VStack {
            if currentTaskIndex < tasks.count {
                let currentTaskType = tasks[currentTaskIndex]
                TaskViewFactory.makeView(for: currentTaskType)
                
                Button(action: {
                    // Переход к следующему заданию
                    currentTaskIndex += 1
                }) {
                    Text("Дальше")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                
            } else {
                Text("Урок завершён!")
                    .font(.title)
                
                // Кнопка для выхода или повторения
                Button(action: {
                    // Например, вернуться в MainView
                    // Или начать заново
                    currentTaskIndex = 0
                }) {
                    Text("Пройти заново")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarTitle("Занятия", displayMode: .inline)
    }
}
