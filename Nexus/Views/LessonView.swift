import SwiftUI

struct LessonView: View {
    @State private var tasks: [DeepseekTask] = []
    @State private var currentTaskIndex: Int = 0
    @State private var answerFeedback: String? = nil
    @State private var isLoading = false
    @State private var showError = false
    @State private var loadRetries = 0
    
    private let apiService = DeepseekAPIService()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                if isLoading {
                    loadingView
                } else if !tasks.isEmpty && currentTaskIndex < tasks.count {
                    taskView
                } else if showError {
                    errorView
                } else if currentTaskIndex >= tasks.count && !tasks.isEmpty {
                    completionView
                } else {
                    Color.clear.onAppear(perform: loadTasks)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLoading)
        .animation(.easeInOut(duration: 0.3), value: currentTaskIndex)
        .animation(.easeInOut(duration: 0.3), value: showError)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text(loadRetries == 0 ? "Loading exercises..." : "Retrying (\(loadRetries)/3)")
                .foregroundColor(.gray)
        }
    }
    
    private var taskView: some View {
        VStack(spacing: 16) {
            // Progress
            HStack {
                Text("Task \(currentTaskIndex + 1) of \(tasks.count)")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
                ProgressView(value: Double(currentTaskIndex), total: Double(tasks.count))
                    .frame(width: 100)
            }
            .padding(.horizontal)
            
            // Current task
            TaskViewFactory.view(
                for: tasks[currentTaskIndex],
                onAnswerSubmitted: handleAnswer
            )
            .transition(.opacity)
            .id(currentTaskIndex) // Force view recreation
            
            // Feedback overlay
            if let feedback = answerFeedback {
                Text(feedback)
                    .font(.system(size: 60))
                    .foregroundColor(feedback == "✅" ? .green : .red)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Failed to load exercises")
                .font(.headline)
            
            Text("Please check your connection and try again")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: loadTasks) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.green)
            
            Text("Lesson Complete! 🎉")
                .font(.title)
            
            Text("Great job!")
                .font(.title2)
                .foregroundColor(.gray)
            
            Button(action: startNewLesson) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start New Lesson")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    private func loadTasks() {
        withAnimation {
            isLoading = true
            showError = false
        }
        
        guard loadRetries < 3 else {
            withAnimation {
                isLoading = false
                showError = true
            }
            return
        }
        
        loadRetries += 1
        
        apiService.fetchLessonTasks { result in
            DispatchQueue.main.async {
                withAnimation {
                    isLoading = false
                    
                    if let tasks = result, !tasks.isEmpty {
                        self.tasks = tasks
                        self.currentTaskIndex = 0
                        self.showError = false
                        self.loadRetries = 0
                    } else if self.loadRetries < 3 {
                        // Автоматически пробуем еще раз
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.loadTasks()
                        }
                    } else {
                        self.showError = true
                    }
                }
            }
        }
    }
    
    private func handleAnswer(isCorrect: Bool) {
        withAnimation {
            answerFeedback = isCorrect ? "✅" : "❌"
        }
        
        if isCorrect {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    answerFeedback = nil
                    currentTaskIndex += 1
                }
            }
        }
    }
    
    private func startNewLesson() {
        tasks = []
        currentTaskIndex = 0
        loadRetries = 0
        loadTasks()
    }
}

#Preview {
    LessonView()
}
