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
    
    // Анимируем фон: будем плавно перебирать цвета градиента
    @State private var animatedGradient = false
    
    var body: some View {
        ZStack {
            // Градиентный фон с анимацией
            LinearGradient(
                gradient: Gradient(colors: animatedGradient ? [Color.blue, Color.purple] : [Color.pink, Color.orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                // Бесконечная анимация плавного переключения
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    animatedGradient.toggle()
                }
            }
            
            VStack(spacing: 0) {
                // Хедер с прогрессом
                VStack(spacing: 16) {
                    // Верхняя строка
                    HStack {
                        Text("Прогресс: \(currentTaskIndex + 1)/\(tasks.count)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        // Кнопка "закрыть"
                        Button(action: {
                            // Допустим, закрытие вью (или что-то свое)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Анимированный прогресс-бар
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.white, Color.white.opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width
                                        * CGFloat(currentTaskIndex + 1) / CGFloat(tasks.count),
                                    height: 8
                                )
                                .animation(.easeInOut(duration: 0.5), value: currentTaskIndex)
                        }
                    }
                    .frame(height: 20)
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
                
                // Контент задания
                Group {
                    if currentTaskIndex < tasks.count {
                        let taskType = tasks[currentTaskIndex]
                        
                        // Анимационный контейнер
                        VStack(spacing: 20) {
                            // Карточка задания
                            VStack(alignment: .leading, spacing: 16) {
                                // Заголовок + иконка
                                HStack(spacing: 12) {
                                    Image(systemName: iconForTaskType(taskType))
                                        .font(.title2)
                                        .padding(10)
                                        .background(taskColorForType(taskType))
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                    
                                    Text(titleForTaskType(taskType))
                                        .font(.title2.weight(.semibold))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                
                                // Вью из фабрики (конкретное задание)
                                TaskViewFactory.makeView(for: taskType)
                                    .padding(.top, 8)
                            }
                            .padding(20)
                            // Полупрозрачный фон с blur
                            .background(
                                BlurView(style: .systemThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                )
                            )
                            
                            Spacer()
                            
                            // Кнопка продолжения
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    currentTaskIndex += 1
                                }
                            }) {
                                HStack {
                                    Text(currentTaskIndex == tasks.count - 1 ? "Завершить урок" : "Следующее задание")
                                        .font(.headline.weight(.semibold))
                                    
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.title3)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.pink, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                            .transition(.opacity)
                        }
                    } else {
                        // Экран завершения
                        VStack(spacing: 30) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.green.opacity(0.2), lineWidth: 8)
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            
                            Text("Урок завершён!")
                                .font(.largeTitle.weight(.bold))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    currentTaskIndex = 0
                                }
                            }) {
                                Text("Пройти заново")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.green, .mint]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                        .padding(.top, 40)
                        .transition(.opacity)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Занятие")
    }
    
    // MARK: - Вспомогательные функции
    
    private func iconForTaskType(_ type: TaskType) -> String {
        switch type {
        case .translation: return "text.book.closed"
        case .sentenceBuilding: return "square.and.pencil"
        case .multipleChoice: return "list.bullet"
        case .matchingPairs: return "arrow.left.arrow.right"
        }
    }
    
    private func titleForTaskType(_ type: TaskType) -> String {
        switch type {
        case .translation:       return "Перевод предложения"
        case .sentenceBuilding:  return "Составление предложения"
        case .multipleChoice:    return "Выбор варианта"
        case .matchingPairs:     return "Сопоставление пар"
        }
    }
    
    private func taskColorForType(_ type: TaskType) -> Color {
        switch type {
        case .translation:      return .orange
        case .sentenceBuilding: return .blue
        case .multipleChoice:   return .purple
        case .matchingPairs:    return .pink
        }
    }
}
